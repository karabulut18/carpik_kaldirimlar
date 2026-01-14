---
description: Update project memory log
---
Use this workflow to update the project's memory log with recent changes.

1. **Read Current Log**
   - Read `memory/current_log.md` to understand the project status and the format of previous entries.

2. **Analyze Changes**
   - Reflect on the recent code changes you have performed or witnessed. 
   - You can use `git status` or `git diff` if you need to refresh your memory, but rely on your context if possible.

3. **Update Log**
   - Append a new entry to `memory/current_log.md`.
   - Use the following format:
     ```markdown
     ### Entry <N> [YYYY-MM-DD HH:MM:SS]
     **Change Abstract:** <One-line summary>

     **Details:**
     - <Point 1>
     - <Point 2>
     ```
   - Increment the Entry number <N> from the last one.

4. **Archive (Optional)**
   - If the log file is very long (e.g., > 20 entries), move older entries to `memory/archives/` and start fresh, updating the main abstract if needed.
