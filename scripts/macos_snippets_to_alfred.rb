#!/usr/bin/env ruby
# frozen_string_literal: true

##
# Convert macOS snippets ("Text Replacement") to Alfred.
#
# Alfred snippets are stored as JSON files in the snippets directory.
# This script reads the macOS text replacements database and exports
# each row as a Alfred-compatible JSON snippet to the current directory.
#
# To use:
#
# 0. make sure you have Ruby installed (macOS comes with Ruby pre-installed)
# 1. Install bundler: `gem install bundler`
# 2. Run this script: `ruby macos_snippets_to_alfred.rb`
# 3. Follow the instructions to import the snippets into Alfred.

require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'json'
  gem 'sqlite3'
end

def print_instructions
  puts <<~DONE
    macOS snippets exported to JSON files and saved at current directory.

    To import into Alfred:

    1. open your Alfred settings directory (right-click on )
    2. in the snippets directory, create a new directory
    3. copy the JSON files into the created directory
  DONE
end

def row_to_alfred_json(row)
  {
    alfredsnippet: {
      keyword: row['ZSHORTCUT'],
      name: '',
      snippet: row['ZPHRASE'],
      uid: row['ZUNIQUENAME']
    }
  }.to_json
end

def save_row_to_file(row)
  File.open(File.expand_path("./#{row['ZUNIQUENAME']}.json"), 'w') do |f|
    f.write row_to_alfred_json(row)
  end
end

def run
  db = SQLite3::Database.new File.expand_path('~/Library/KeyboardServices/TextReplacements.db')
  db.results_as_hash = true

  db.execute('select ZUNIQUENAME, ZSHORTCUT, ZPHRASE from ZTEXTREPLACEMENTENTRY where ZWASDELETED = 0;') do |row|
    save_row_to_file row
  end

  print_instructions
end

run
