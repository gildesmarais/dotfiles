# Entry points for this machine's dotfiles. rcup's hooks/post-up converges mise.
SKILL := ./scripts/skill

.PHONY: up install

# Sync an installed machine: pull, relink, check the skill store.
up:
	git pull
	rcup -v
	$(SKILL) prune
	$(SKILL) lint

# Bootstrap a fresh clone; Homebrew must already be installed.
install:
	brew bundle
	rcup -v
	$(SKILL) lint
