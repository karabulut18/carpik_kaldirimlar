import json
import os
import datetime
from pathlib import Path

CONFIG_PATH = Path("memory/config.json")
ARCHIVE_DIR = Path("memory/archives")

def load_config():
    if not CONFIG_PATH.exists():
        return {
            "prompt_count": 0,
            "archive_threshold": 20,
            "current_log": "memory/current_log.md",
            "abstract": ""
        }
    with open(CONFIG_PATH, "r") as f:
        return json.load(f)

def save_config(config):
    with open(CONFIG_PATH, "w") as f:
        json.dump(config, f, indent=2)

def archive_log(config, new_abstract):
    old_log = Path(config["current_log"])
    if old_log.exists():
        timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        archive_path = ARCHIVE_DIR / f"log_{timestamp}.md"
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
    
    # Ensure file exists
    if not current_log_path.exists():
        with open(current_log_path, "w") as f:
            f.write(f"# Project Memory Log\n\n## Abstract\n{config['abstract']}\n\n## Log Entries\n")

    # Append message
    timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(current_log_path, "a") as f:
        f.write(f"\n### Entry {config['prompt_count']} [{timestamp}]\n")
        if entry_abstract:
            f.write(f"**Change Abstract:** {entry_abstract}\n\n")
        f.write(f"**Details:**\n{message}\n")

    print(f"Logged entry {config['prompt_count']}.")

    # Check for archive
    if config["prompt_count"] >= config["archive_threshold"]:
        archive_log(config, global_abstract_update or config["abstract"])
    
    save_config(config)

if __name__ == "__main__":
    import sys
    if len(sys.argv) < 2:
        print("Usage: python logger.py 'message' ['entry_abstract'] ['global_abstract']")
    else:
        msg = sys.argv[1]
        entry_abs = sys.argv[2] if len(sys.argv) > 2 else None
        global_abs = sys.argv[3] if len(sys.argv) > 3 else None
        log_message(msg, entry_abs, global_abs)
