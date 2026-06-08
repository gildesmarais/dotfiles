#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler'
require 'net/http'
require 'uri'

# 1. Parse the local Gemfile.lock to extract precise gem names and versions
begin
  lockfile = Bundler::LockfileParser.new(Bundler.read_file('Gemfile.lock'))

  # Gather all locked dependencies as unique pairs [name, version]
  dependencies = lockfile.specs.map { |spec| [spec.name, spec.version.to_s] }.uniq.sort
rescue Errno::ENOENT
  puts '❌ Error: Gemfile.lock not found in the current directory.'
  exit 1
end

puts "Found #{dependencies.size} unique dependencies in Gemfile.lock."
puts 'Auditing Trusted Publishing status via HTML inspection on RubyGems.org...'
puts '--------------------------------------------------------------------------------'

results = {}
mutex = Mutex.new
threads = []
MAX_THREADS = 15 # Concurrency limit to safely batch requests without triggering rate blocks

queue = Queue.new
dependencies.each { |name, version| queue << [name, version] }

# Helper function to reliably trace and parse the HTML version page
def verify_gem_provenance(name, version)
  uri = URI("https://rubygems.org/gems/#{name}/versions/#{version}")

  # Follow up to 3 redirects if RubyGems normalizes or updates the canonical URI
  3.times do
    response = Net::HTTP.get_response(uri)

    case response
    when Net::HTTPSuccess
      html = response.body

      # Strict substring validation against the rendered UI element visible in the browser.
      # If the provenance box exists, these key localized phrases are guaranteed to be in the DOM.
      if html.include?('Built and signed on') || html.include?('transparency log entry')
        return { trusted: true, version: version }
      end

      return { trusted: false, version: version }

    when Net::HTTPRedirection
      uri = URI.join(uri.to_s, response['location'])
    when Net::HTTPNotFound
      return { trusted: false, version: version, error: '404 Not Found (Possibly private or yanked)' }
    else
      return { trusted: false, version: version, error: "HTTP #{response.code}" }
    end
  end

  { trusted: false, version: version, error: 'Too many redirects encountered' }
end

# 2. Spawn concurrent worker threads to batch process the queue
MAX_THREADS.times do
  threads << Thread.new do
    until queue.empty?
      name, version = begin
        queue.pop(true)
      rescue StandardError
        nil
      end
      next unless name

      res = verify_gem_provenance(name, version)
      mutex.synchronize { results[name] = res }
    end
  end
end

threads.each(&:join)

# 3. Format and output final strict classifications
trusted_gems = results.select { |_, data| data[:trusted] }
untrusted_gems = results.reject { |_, data| data[:trusted] }

puts "\n### GEMS USING TRUSTED PUBLISHING OIDC ATTESTATIONS (#{trusted_gems.size}/#{dependencies.size}) ###"
trusted_gems.sort.each do |name, data|
  puts "✅ #{name} (v#{data[:version]})"
end

puts "\n### GEMS LACKING OIDC ATTESTATIONS (MANUAL, TOKEN, OR CUSTOM) (#{untrusted_gems.size}/#{dependencies.size}) ###"
untrusted_gems.sort.each do |name, data|
  reason = data[:error] ? " [#{data[:error]}]" : ''
  puts "❌ #{name} (v#{data[:version]})#{reason}"
end
