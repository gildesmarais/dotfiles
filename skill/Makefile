SYSTEM_RUBY := /System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/bin/ruby
RUBOCOP := $(shell command -v rubocop)
RUBOCOP_BIN_DIR := $(dir $(RUBOCOP))

.PHONY: test lint

test:
	$(SYSTEM_RUBY) -Itest -e 'Dir["test/*_test.rb"].sort.each { |file| require File.expand_path(file) }'

lint:
	mkdir -p .cache
	PATH="$(RUBOCOP_BIN_DIR):$(PATH)" XDG_CACHE_HOME=$(CURDIR)/.cache $(RUBOCOP) -c .rubocop.yml ../scripts/skill src test
