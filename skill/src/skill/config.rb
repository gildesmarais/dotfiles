# frozen_string_literal: true

require "yaml"

module Skill
  class Config
    DEFAULT_STORE_DIR = "skills"
    CENTRAL_ALLOWED_KEYS = %w[defaults ignore required store_dir tools].freeze
    PROJECT_ALLOWED_KEYS = %w[authoring_tool extra_destinations ignore required tools].freeze
    DEFAULTS_ALLOWED_KEYS = %w[authoring_tool tools].freeze
    TOOL_PROFILE_ALLOWED_KEYS = %w[authoring destinations].freeze
    DEFAULT_TOOL_PROFILES = {
      "codex" => {
        "destinations" => [".codex/skills"],
        "authoring" => true
      }
    }.freeze
    DEFAULT_TOOLS = ["codex"].freeze

    attr_reader :active_tools,
                :authoring_destination,
                :authoring_tool,
                :central_config_path,
                :destinations,
                :ignored,
                :mirror_destinations,
                :project_config_path,
                :required,
                :store_dir

    def self.load(project_root, dotfiles_root, env = ENV)
      central_path = central_config_path(env)
      project_path = File.join(project_root, ".skill.yml")

      new(
        dotfiles_root: dotfiles_root,
        project_root: project_root,
        central: {
          path: central_path,
          data: load_yaml(central_path)
        },
        project: {
          path: project_path,
          data: load_yaml(project_path)
        }
      )
    end

    def self.central_config_path(env = ENV)
      xdg_config_home = env["XDG_CONFIG_HOME"]
      home_dir = env["HOME"] || ENV["HOME"] || File.expand_path("~")
      base_dir = if xdg_config_home.nil? || xdg_config_home.empty?
                   File.join(home_dir, ".config")
                 else
                   File.expand_path(xdg_config_home)
                 end

      File.join(base_dir, "skill", "config.yml")
    end

    def self.load_yaml(path)
      return {} unless File.exist?(path)

      data = YAML.safe_load(File.read(path))
      return {} if data.nil?
      return data if data.is_a?(Hash)

      raise ExitError, "invalid YAML in #{path}: expected a mapping at the top level"
    rescue Psych::SyntaxError => e
      raise ExitError, "invalid YAML in #{path}: #{e.message}"
    end

    def initialize(dotfiles_root:, project_root:, central:, project:)
      @dotfiles_root = dotfiles_root
      @project_root = project_root
      @central_config_path = central[:path]
      @project_config_path = project[:path]
      @central_data = validate_mapping(central[:data], @central_config_path, CENTRAL_ALLOWED_KEYS)
      @project_data = validate_mapping(project[:data], @project_config_path, PROJECT_ALLOWED_KEYS)

      @store_dir = resolve_store_dir
      @required = unique_strings(string_list(@central_data, "required", @central_config_path),
                                 string_list(@project_data, "required", @project_config_path))
      @ignored = unique_strings(string_list(@central_data, "ignore", @central_config_path),
                                string_list(@project_data, "ignore", @project_config_path))

      profiles = resolve_tool_profiles
      @active_tools = resolve_active_tools(profiles)
      @authoring_tool = resolve_authoring_tool(profiles)
      @destinations = resolve_destinations(profiles)
      @authoring_destination = resolve_authoring_destination(profiles)
      @mirror_destinations = @destinations.reject { |dest| dest == @authoring_destination }
    end

    def ignored?(name)
      @ignored.include?(name)
    end

    private

    def resolve_store_dir
      raw_store_dir = string_value(@central_data, "store_dir", @central_config_path) || DEFAULT_STORE_DIR
      expanded = File.expand_path(raw_store_dir.to_s)
      return expanded if path_absolute?(raw_store_dir.to_s)

      File.expand_path(raw_store_dir.to_s, @dotfiles_root)
    end

    def resolve_tool_profiles
      profiles = deep_copy(DEFAULT_TOOL_PROFILES)
      custom_profiles = @central_data["tools"]
      return profiles unless custom_profiles.is_a?(Hash)

      custom_profiles.each do |name, raw_profile|
        normalized_name = name.to_s
        profile_path = "#{@central_config_path}:tools.#{normalized_name}"
        profile_data = validate_mapping(raw_profile, profile_path, TOOL_PROFILE_ALLOWED_KEYS)
        existing = profiles[normalized_name] || {}
        profiles[normalized_name] = {
          "destinations" => normalize_destinations(
            profile_data.key?("destinations") ? profile_data["destinations"] : existing["destinations"],
            profile_path
          ),
          "authoring" => truthy?(profile_data.key?("authoring") ? profile_data["authoring"] : existing["authoring"],
                                 "#{profile_path}.authoring")
        }
      end

      profiles
    end

    def resolve_active_tools(profiles)
      defaults = defaults_data
      tools = string_list(@project_data, "tools", @project_config_path)
      tools = string_list(defaults, "tools", "#{@central_config_path}:defaults") if tools.empty?
      tools = DEFAULT_TOOLS if tools.empty?
      raise ExitError, "no active tools configured" if tools.empty?

      unknown = tools.reject { |name| profiles.key?(name) }
      raise ExitError, "unknown configured tool(s): #{unknown.sort.join(', ')}" unless unknown.empty?

      tools
    end

    def resolve_authoring_tool(profiles)
      raw_authoring = string_value(@project_data, "authoring_tool", @project_config_path)
      if blank?(raw_authoring)
        raw_authoring = string_value(defaults_data, "authoring_tool", "#{@central_config_path}:defaults")
      end

      authoring_tool = raw_authoring.to_s unless blank?(raw_authoring)
      if blank?(authoring_tool)
        authoring_tool = @active_tools.find { |name| truthy?(profiles.fetch(name, {})["authoring"]) }
      end
      authoring_tool = @active_tools.first if blank?(authoring_tool)

      unless @active_tools.include?(authoring_tool)
        raise ExitError, "authoring tool is not active for this project: #{authoring_tool}"
      end

      authoring_tool
    end

    def resolve_destinations(profiles)
      destinations = []

      @active_tools.each do |tool_name|
        tool_destinations = profiles.fetch(tool_name, {})["destinations"]
        destinations.concat(normalize_destinations(tool_destinations, "tool profile #{tool_name}"))
      end

      destinations.concat(normalize_destinations(@project_data["extra_destinations"],
                                                 "#{@project_config_path}:extra_destinations"))
      destinations = unique_strings(destinations)

      raise ExitError, "no project skill destinations configured" if destinations.empty?

      destinations
    end

    def resolve_authoring_destination(profiles)
      authoring_profile = profiles.fetch(@authoring_tool, {})
      tool_destinations = normalize_destinations(authoring_profile["destinations"],
                                                 "tool profile #{@authoring_tool}")

      destination = tool_destinations.first
      raise ExitError, "authoring tool has no destinations configured: #{@authoring_tool}" if blank?(destination)

      destination
    end

    def defaults_data
      @defaults_data ||= validate_mapping(@central_data.fetch("defaults", {}),
                                          "#{@central_config_path}:defaults",
                                          DEFAULTS_ALLOWED_KEYS)
    end

    def validate_mapping(data, path, allowed_keys)
      raise ExitError, "invalid config at #{path}: expected a mapping" unless data.is_a?(Hash)

      normalized = {}
      data.each do |key, value|
        normalized[key.to_s] = value
      end

      unknown_keys = normalized.keys - allowed_keys
      return normalized if unknown_keys.empty?

      raise ExitError, "unknown config key(s) in #{path}: #{unknown_keys.sort.join(', ')}"
    end

    def string_list(data, key, path)
      value = data[key]
      return [] if value.nil?
      raise ExitError, "invalid config at #{path}: #{key} must be an array of strings" unless value.is_a?(Array)

      value.each_with_index.map do |item, index|
        string_item(item, "#{path}:#{key}[#{index}]")
      end
    end

    def string_value(data, key, path)
      value = data[key]
      return nil if value.nil?

      string_item(value, "#{path}:#{key}")
    end

    def normalize_destinations(destinations, path)
      return [] if destinations.nil?
      unless destinations.is_a?(Array)
        raise ExitError, "invalid config at #{path}: destinations must be an array of strings"
      end

      destinations.each_with_index.map do |destination, index|
        string_item(destination, "#{path}:destinations[#{index}]")
      end
    end

    def unique_strings(*values)
      seen = {}

      values.flatten.compact.map(&:to_s).reject(&:empty?).each_with_object([]) do |value, items|
        next if seen.key?(value)

        seen[value] = true
        items << value
      end
    end

    def string_item(value, path)
      raise ExitError, "invalid config at #{path}: expected a string" unless value.is_a?(String)

      item = value.strip
      raise ExitError, "invalid config at #{path}: value must not be empty" if item.empty?

      item
    end

    def truthy?(value, path = nil)
      return value if [true, false].include?(value)
      return false if value.nil?
      raise ExitError, "invalid config boolean value: #{value.inspect}" if path.nil?

      raise ExitError, "invalid config at #{path}: expected true or false"
    end

    def deep_copy(hash)
      case hash
      when Hash
        hash.each_with_object({}) do |(key, value), result|
          result[deep_copy(key)] = deep_copy(value)
        end
      when Array
        hash.map { |value| deep_copy(value) }
      when String
        hash.dup
      else
        hash
      end
    end

    def blank?(value)
      value.nil? || value.to_s.empty?
    end

    def path_absolute?(path)
      path.start_with?("/", "~")
    end
  end
end
