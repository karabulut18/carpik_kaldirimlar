import json
import os
import datetime
import subprocess
import sys
from pathlib import Path
from google import genai
from google.genai import types

CONFIG_PATH = Path("memory/config.json")
ARCHIVE_DIR = Path("memory/archives")

def load_config():
    if not CONFIG_PATH.exists():
        return {
            "prompt_count": 0,
            "archive_threshold": 20,
            "current_log": "memory/current_log.md",
            "abstract": "",
            "usage": "python3 memory/logger.py --smart"
        }
    with open(CONFIG_PATH, "r") as f:
        return json.load(f)

def save_config(config):
    with open(CONFIG_PATH, "w") as f:
        json.dump(config, f, indent=2)

def get_git_changes():
    try:
        # Get unstaged changes
        diff = subprocess.check_output(["git", "diff"], text=True)
        # Get staged changes
        diff_cached = subprocess.check_output(["git", "diff", "--cached"], text=True)
        # Get untracked files
        untracked = subprocess.check_output(["git", "ls-files", "--others", "--exclude-standard"], text=True)
        
        changes = f"Unstaged Changes:\n{diff}\n\nStaged Changes:\n{diff_cached}\n\nUntracked Files:\n{untracked}"
        return changes
    except subprocess.CalledProcessError:
        return "Error retrieving git changes."

def get_recent_logs(log_path, limit=3):
    if not os.path.exists(log_path):
        return "No recent logs."
    
    try:
        with open(log_path, "r") as f:
            content = f.read()
            # Split by "### Entry" and take the last few
            entries = content.split("### Entry")
            if len(entries) > 1:
                # Reconstruct the last few entries
                recent = "### Entry".join(entries[-limit:])
                return "### Entry" + recent
            return content
    except Exception:
        return "Error reading recent logs."

def load_env_file():
    env_path = Path(".env")
    if not env_path.exists():
        # Try memory/.env as fallback
        env_path = Path("memory/.env")
        
    if env_path.exists():
        with open(env_path, "r") as f:
            for line in f:
                line = line.strip()
                if not line or line.startswith("#"):
                    continue
                if "=" in line:
                    key, value = line.split("=", 1)
                    # Removing quotes if present
                    value = value.strip('"').strip("'")
                    os.environ[key.strip()] = value

def call_gemini_api(changes, current_abstract, recent_logs):
    load_env_file() # Load environment variables before checking
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        print("Error: GEMINI_API_KEY environment variable not set.")
        sys.exit(1)

    client = genai.Client(api_key=api_key)
    
    prompt = f"""
    You are an AI project logger. Update the project memory log based on the recent code changes.
    Maintain the style and format of the recent log entries provided below.
    
    Current Project Abstract:
    {current_abstract}
    
    Recent Log Entries (Context & Style):
    {recent_logs}
    
    Recent Code Changes (Git Diff):
    {changes}
    
    Task:
    Generate a concise project log entry in JSON format with the following keys:
    - "entry_abstract": A one-line summary of the changes (e.g., "Refactored User model and updated security rules").
    - "details": A detailed but concise description of technical changes, bulleted list preferred in Markdown.
    - "global_abstract_update": (Optional) A new version of the global project abstract if these changes significantly shift the project scope. Otherwise null.
    
    Output JSON only.
    """
    
    try:
        response = client.models.generate_content(
            model='gemini-2.0-flash-exp',
            contents=prompt,
            config=types.GenerateContentConfig(
                response_mime_type='application/json'
            )
        )
        return json.loads(response.text)
    except Exception as e:
        print(f"Error calling Gemini SDK: {e}")
        sys.exit(1)

def archive_log(config, new_abstract):
    old_log = Path(config["current_log"])
    if old_log.exists():
        timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        archive_path = ARCHIVE_DIR / f"log_{timestamp}.md"
        ARCHIVE_DIR.mkdir(parents=True, exist_ok=True)
        os.rename(old_log, archive_path)
        print(f"Archived current log to {archive_path}")

    config["prompt_count"] = 0
    config["abstract"] = new_abstract
    
    with open(config["current_log"], "w") as f:
        f.write(f"# Project Memory Log\n\n## Abstract\n{new_abstract}\n\n## Log Entries\n")
    
    print("Started new log file with updated abstract.")

def log_message(message, entry_abstract=None, global_abstract_update=None):
    config = load_config()
    config["prompt_count"] += 1
    
    current_log_path = Path(config["current_log"])
    
    if not current_log_path.exists():
        current_abstract = global_abstract_update if global_abstract_update else config.get("abstract", "")
        with open(current_log_path, "w") as f:
            f.write(f"# Project Memory Log\n\n## Abstract\n{current_abstract}\n\n## Log Entries\n")
    
    if global_abstract_update:
        config["abstract"] = global_abstract_update

    timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(current_log_path, "a") as f:
        f.write(f"\n### Entry {config['prompt_count']} [{timestamp}]\n")
        if entry_abstract:
            f.write(f"**Change Abstract:** {entry_abstract}\n\n")
        f.write(f"**Details:**\n{message}\n")

    print(f"Logged entry {config['prompt_count']}.")

    if config["prompt_count"] >= config["archive_threshold"]:
        archive_log(config, config["abstract"])
    
    save_config(config)

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--smart":
        config = load_config()
        changes = get_git_changes()
        recent_logs = get_recent_logs(config["current_log"])
        print("Analyzing changes with Gemini SDK...")
        try:
            ai_response = call_gemini_api(changes, config.get("abstract", ""), recent_logs)
            log_message(
                ai_response["details"], 
                ai_response.get("entry_abstract"), 
                ai_response.get("global_abstract_update")
            )
        except Exception as e:
            print(f"Smart logger failed: {e}")
            sys.exit(1)
    elif len(sys.argv) < 2:
        print("Usage: python logger.py 'message' ['entry_abstract'] ['global_abstract']")
        print("   OR: python logger.py --smart")
    else:
        msg = sys.argv[1]
        entry_abs = sys.argv[2] if len(sys.argv) > 2 else None
        global_abs = sys.argv[3] if len(sys.argv) > 3 else None
        log_message(msg, entry_abs, global_abs)
