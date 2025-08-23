#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rubygems'

begin
  require 'reline/face'
rescue LoadError
  puts "The 'reline' gem is not installed. Please install it to use this feature."
end

# Disable multiline mode to improve pasting speed on macOS
IRB.conf[:USE_MULTILINE] = false
# Improve pasting speed on macos.
#
# source: https://github.com/ruby/irb/issues/43#issuecomment-572981408
IRB.conf[:USE_MULTILINE] = false

Reline::Face.config(:completion_dialog) do |conf|
  conf.define :default, foreground: :white, background: :blue
  #                                                     ^^^^^ `:cyan` by default
  conf.define :enhanced, foreground: :white, background: :magenta
  conf.define :scrollbar, foreground: :white, background: :blue
end

##
# Refinements for IRB session
class Class
  # Show only this class class methods
  def class_methods = (methods - Class.instance_methods - Object.methods).sort

  # Show instance and class methods
  def defined_methods
    { instance: new.local_methods, class: class_methods }
  end
end

class Object
  # returns local methods (defined on this object)
  def local_methods(obj = self) = (obj.methods - obj.class.superclass.instance_methods).sort

  # copies input to clipboard (mac os only)
  def pbcopy(input) = IO.popen('pbcopy', 'w') { |io| io.puts input }

  # pastes from the clipboard (macos only)
  def pbpaste = IO.popen('pbpaste', 'r', &:read)
end
