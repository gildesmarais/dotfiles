#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rubygems'

##
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
# monkey-patch (restricted to irb session) Class
class Class
  ##
  # Show only this class class methods
  def class_methods
    (methods - Class.instance_methods - Object.methods).sort
  end

  ##
  # Show instance and class methods
  def defined_methods
    { instance: new.local_methods, class: class_methods }
  end
end

##
# monkey-patch (restricted to irb session) Object
class Object
  ##
  # returns local methods (defined on this object)
  def local_methods(obj = self)
    (obj.methods - obj.class.superclass.instance_methods).sort
  end

  ##
  # copies input to clipboard (mac os only)
  def pbcopy(input)
    str = input.to_s
    IO.popen('pbcopy', 'w') { |f| f << str }
    str
  end

  ##
  # pastes from the clipboard (macos only)
  def pbpaste
    `pbpaste`
  end
end
