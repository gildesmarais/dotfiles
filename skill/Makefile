SYSTEM_RUBY := /System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/bin/ruby
RUBOCOP := $(shell command -v rubocop)
RUBOCOP_BIN_DIR := $(dir $(RUBOCOP))

.PHONY: test lint

test:
	$(SYSTEM_RUBY) -Itest test/cli_test.rb

lint:
	mkdir -p .cache
	PATH="$(RUBOCOP_BIN_DIR):$(PATH)" XDG_CACHE_HOME=$(CURDIR)/.cache $(RUBOCOP) -c .rubocop.yml ../scripts/skill src/cli.rb test/cli_test.rb
