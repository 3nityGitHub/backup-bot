# Backup Bot

A self-verifying backup toolkit: four Bash scripts that compress a directory into a
timestamped archive and then prove the archive is actually readable before declaring
success. Built to practise the full Linux + Git workflow end to end.

## What it does

| Script           | Job                                                                                 |
|------------------|-------------------------------------------------------------------------------------|
| `precheck.sh`    | Verify the required tools (`tar`, `gzip`) are installed. Exit non-zero if any are missing. |
| `backup.sh`      | Takes a source dir and a destination dir. Validates both, confirms the source exists, runs precheck, then creates a timestamped `tar -czf backup-YYYYMMDD-HHMMSS.tar.gz` into the destination. Reports the archive path and size. |
| `verify.sh`      | Takes an archive path. Confirms the file exists and is a valid archive (`tar -tzf` reads it without error), then reports how many files it contains. |
| `backup-all.sh`  | Chains backup → verify with `set -euo pipefail`, stopping at the first failure.      |

## Requirements

`tar` and `gzip`, plus a source directory that exists. `precheck.sh` checks the tools
and exits non-zero if either is missing; `backup.sh` checks the source directory.

## Usage

```bash
# Check that the archive tools are available
./precheck.sh

# Back up a source directory into a destination directory
./backup.sh ~/testsrc ~/backups

# Verify an archive is readable and count its files
./verify.sh ~/backups/backup-*.tar.gz

# Full pipeline: backup then verify, stops at the first failure
./backup-all.sh ~/testsrc ~/backups
```

## How it works together

`backup-all.sh` begins with `set -euo pipefail`, so if any step fails the whole
pipeline stops immediately — a failed backup can never reach the verify step.
`backup.sh` runs `precheck.sh` itself, so the tools are always checked before a
backup begins. Because `backup.sh` generates the archive name with a timestamp
*inside itself*, `backup-all.sh` can't know the filename in advance — so after the
backup runs it finds the newest `.tar.gz` in the destination folder
(`ls -t ... | head -1`) and passes that to `verify.sh`.

The design mirrors a real deployment pipeline: check prerequisites, do the work,
then **prove the work succeeded** rather than assuming it did.

## What broke and how I fixed it

**Comma in the tool list.** I wrote `TOOLS="tar, gzip"`. The loop split that into
`tar,` (with a comma) and checked for a command literally named `tar,`, which doesn't
exist, so precheck wrongly failed. Fixed by removing the comma — space-separated only.

**Missing `$` on a variable.** My archive path read `FINAL_DIR/backup-...` instead of
`$FINAL_DIR/...`. Without the `$`, bash treated it as the literal word "FINAL_DIR", so
tar tried to write into a folder that didn't exist. The error path gave it away — it
showed `FINAL_DIR/` instead of `/home/rapheal26/backups/`. Fixed by adding the `$`.

**`#` instead of `$` in a message.** My corrupt-archive message printed the literal
text `#ARCHIVE_PATH` instead of the path. Fixed the sigil to `$`.

**A stray bare `tar` line.** `verify.sh` had a bare `tar -tzf` above my guarded check.
On a corrupt archive it failed first and, under `set -e`, killed the script showing
tar's raw error before my clean message could run. Removed the redundant line so the
guarded `if ! tar ... >/dev/null 2>&1` controls the output.

**The archive-path design puzzle.** `verify.sh` needs the archive path, but
`backup.sh` only knows it after it runs (timestamp). I first tried passing it as an
argument — impossible, the file doesn't exist yet. Solved it by finding the newest
`.tar.gz` in the destination after the backup completes.

## What I learned

- `tar -czf` to create a compressed archive, `tar -tzf` to list/validate one.
- Command substitution (`VAR=$(...)`) to capture a command's output — used to grab the
  newest archive path.
- Controlling my own error output: catching a tool's failure with `if !` and silencing
  it with `>/dev/null 2>&1`, so the user sees my message, not the tool's internals.
- Reading the error path/message as the first debugging move, not the last.

## Known improvements

- Standardise `set -euo pipefail` across all four scripts (currently mixed).
- `ls -t | head -1` assumes no other process writes to the destination between backup
  and verify; a more robust version would capture the exact path from `backup.sh`.
