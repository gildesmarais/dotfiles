#!/usr/bin/env ruby

require 'rubygems'

class Object
  def local_methods(obj = self)
    (obj.methods - obj.class.superclass.instance_methods).sort
  end
end

def pbcopy(input)
  str = input.to_s
  IO.popen('pbcopy', 'w') { |f| f << str }
  str
end

def pbpaste
  `pbpaste`
end

# improve pasting speed. src: https://github.com/ruby/irb/issues/43#issuecomment-572981408
IRB.conf[:USE_MULTILINE] = false
