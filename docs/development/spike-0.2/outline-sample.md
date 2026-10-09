---
spec: specs/010-pager/spec.md
spec_blob: df3ba8c1c9f71299d987314222f3dd42c46706f5
prefix: PGR
level: 4
---

## PGR-01 Paging modes and output file
- size: S
- spec: TTY Detection and Paging Modes
- does: A --paging option accepts auto, always and never, defaults to auto, and rejects any other value
- does: -P is a short form of --paging never
- does: With auto, a pager is wanted only when stdout is a TTY and no output file is given
- does: With always, a pager is wanted whether or not stdout is a TTY; with never, it is not wanted
- does: --output <file> and -o <file> write output to the file and turn paging off
- does: The decision to page is made at start, before any output is generated
- not: Choosing the pager program (PGR-06, PGR-07)
- not: What never does to candidate evaluation (PGR-10)

## PGR-02 Safe pager launch
- size: S
- depends: PGR-01
- spec: Pager Execution and Security
- does: A pager command is run directly from PATH, never through a shell
- does: A value such as "less -X" is split into words with shell-style quoting, without running a shell
- does: Whether a pager command exists on PATH and is executable can be checked before it is started
- does: When paging is wanted, the pager process is started at application start, before any output is generated
- not: Which pager is the default (PGR-03)
- not: What happens when the check fails or the start fails (PGR-07, PGR-13)

## PGR-03 Default pager profiles
- size: S
- depends: PGR-02, PGR-04
- spec: Default Pager Behavior
- spec: Pager Execution and Security
- does: The default configuration defines a less profile with command less, args -R and env LESSCHARSET=UTF-8
- does: The default configuration defines an fzf profile with command fzf, view args --layout=reverse-list, and follow enabled with follow args --tac --track
- does: less is the default pager on every platform, including Windows, when no other pager is configured or set
- does: A pager taken from HL_PAGER or PAGER as a raw command string, not a profile, gets no added arguments or environment
- not: The order of the default candidates (PGR-07)

## PGR-04 Pager configuration schema
- size: M
- spec: Configuration
- does: pager.candidates accepts { env = "VAR" }, { env = { pager, follow, delimiter } } and { profile = "name" } entries
- does: A candidate with both env and profile is rejected with a clear error
- does: An env candidate accepts a profiles boolean that defaults to false
- does: [[pager.profiles]] entries accept name, command, args, env, modes.view.args, modes.follow.enabled and modes.follow.args
- does: Two profiles with the same name are rejected
- does: A profile accepts delimiter, either newline or nul, and rejects other values
- does: The legacy pager string or array and the [pagers] section are read into the same structures
- not: Conditions on profiles (PGR-05)
- not: Where a legacy pager setting ranks among candidates (PGR-10)
- not: Choosing among candidates (PGR-06)

## PGR-05 Profile conditions
- size: S
- depends: PGR-04
- spec: Configuration
- does: A profile conditions entry has an if string and optional args and env
- does: The conditions os:macos, os:linux, os:windows, os:unix, mode:view and mode:follow match, and a leading ! negates them
- does: All matching conditions are applied in the order written
- not: The profile schema itself (PGR-04)
- not: Placing condition args in the pager command (PGR-08)

## PGR-06 Candidate selection
- size: M
- depends: PGR-02, PGR-04
- spec: Candidate-Based Selection
- does: Candidates are tried in array order until a usable one is found
- does: A profile candidate is selected when the profile exists and its command is on PATH, whatever the mode
- does: A profile candidate whose profile is missing, whose command array is empty or whose command is not on PATH is skipped
- does: When no candidate is usable, output goes to stdout with no error shown
- does: Selection decisions and failures are written to the debug log when HL_DEBUG_LOG is set
- does: Reading a legacy pager or [pagers] setting logs a deprecation warning when HL_DEBUG_LOG is set
- not: Env candidates (PGR-07)

## PGR-07 Environment variable candidates
- size: M
- depends: PGR-06, PGR-08
- spec: Environment Variable Handling
- spec: Candidate-Based Selection
- does: A simple env candidate is used in view mode and skipped in follow mode
- does: A structured env candidate uses its pager variable in view mode and its follow variable in follow mode, and pages in follow mode only if the follow variable resolves
- does: A structured env candidate takes the delimiter from its delimiter variable for a direct command, and uses newline when that variable is unset or empty
- does: An empty env variable counts as not set, so a simple candidate is skipped and an empty field of a structured candidate is unset
- does: With profiles = true, a value starting with @ names a profile, built as in PGR-08, and the follow and delimiter fields are ignored for it
- does: With profiles = false, an @ is part of the command name
- does: An env value that names a missing profile, or a direct command that the check of PGR-02 finds missing, prints an error and exits non-zero, with no fallback
- does: The default candidates are the HL_PAGER structured entry with profiles = true, then fzf, then less, then PAGER
- not: Profile candidates and the fallback to stdout (PGR-06)
- not: Arguments added to a raw command string (PGR-03)
- not: A command that passes the check but fails to start (PGR-13)

## PGR-08 Role-specific arguments
- size: S
- depends: PGR-04, PGR-05, PGR-06
- spec: Role-Based Arguments
- does: In view mode the pager runs with the profile command, its args, the args of matching conditions, then view args, with the profile env set
- does: In follow mode with follow.enabled = true it runs with the command, its args, the args of matching conditions, then follow args, with the profile env set
- does: In follow mode with follow.enabled unset or false, paging is off, lower candidates are not tried, and --paging always does not change this
- not: Stopping follow mode when the pager exits (PGR-09)

## PGR-09 Follow mode and pager closure
- size: XS
- depends: PGR-08, PGR-12
- spec: Follow Mode Pager Behavior
- does: When the pager closes in follow mode, following stops and the application exits cleanly
- does: No new follow output is read once the pager has closed
- not: Detecting the closed pipe (PGR-12)

## PGR-10 Paging precedence
- size: S
- depends: PGR-01, PGR-04, PGR-07
- spec: Precedence
- does: With --paging never or -P no candidate is evaluated, so an unavailable HL_PAGER command does not cause an error exit, in both view and follow mode
- does: A legacy pager setting ranks after the HL_PAGER candidate and before PAGER, so HL_PAGER beats config and config beats PAGER
- does: View and follow mode use the same candidate order
- not: How a candidate is chosen (PGR-06, PGR-07)

## PGR-11 Pager exit codes
- size: S
- depends: PGR-02
- spec: Pager Exit Code Handling
- does: A pager that exits with code 0 gives exit code 0
- does: A pager that exits with a non-zero code gives exit code 141
- does: A broken pipe on a write does not change the exit code; the code comes from the pager's own exit status
- not: A pager ended by a signal (PGR-12)

## PGR-12 Pager closure and killed pager
- size: S
- depends: PGR-02, PGR-11
- spec: Pager Lifecycle and Error Handling
- does: SIGPIPE is ignored while writing to the pager, and a failed write to the pager is taken as the pager having closed, not as an error
- does: The application exits within 1 second of the pager exiting with code 0
- does: When the pager ends by a signal, stderr gets "hl: pager killed", ANSI formatting is reset with ESC[0m, terminal echo is restored with stty echo, and the exit code is 141
- does: The pager process is waited for, so none is left as a zombie
- not: Exit codes for a pager that exits by itself (PGR-11)
- not: A pager that cannot be started (PGR-13)

## PGR-13 Pager launch failure
- size: XS
- depends: PGR-02
- spec: Pager Lifecycle and Error Handling
- does: A pager that passes the check but fails to start prints "hl: unable to launch pager: <name>: <error>" to stderr
- does: After that failure, paging is off and output goes to stdout
- not: A pager command found missing by the check (PGR-07)
