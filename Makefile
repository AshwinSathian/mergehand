.PHONY: test lint bench validate

# The whole suite, under the system bash (3.2 on macOS).
test:
	/bin/bash test/run.sh

lint:
	shellcheck -x -s bash bin/card hooks/*.sh scripts/*.sh test/*.sh test/cases/*.sh test/stubs/*

# Wall time the post-tool-use hook adds to a tool call.
bench:
	/bin/bash scripts/bench-hook.sh

# Needs Claude Code on PATH.
validate:
	claude plugin validate --strict .
	claude plugin validate --strict .claude-plugin/plugin.json
	claude plugin validate --strict agents
	claude plugin validate --strict skills
