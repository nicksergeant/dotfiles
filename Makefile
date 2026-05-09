.PHONY: install-hooks help

help:
	@echo "Targets:"
	@echo "  make install-hooks   Install git hooks (runs once per clone)"

install-hooks:
	git config core.hooksPath .githooks
	@echo "Hooks installed: git will use .githooks/ for this clone."
	@echo "Pre-commit will:"
	@echo "  - on staged .nix files: nixfmt --check + statix check + deadnix --fail"
	@echo "  - on staged shell scripts (.sh ext or bash/sh shebang): shellcheck"
	@echo "  - on staged text files: typos (allowlist: _typos.toml)"
	@echo "  - on .nix or flake.lock changes under nix/: nix flake check"
