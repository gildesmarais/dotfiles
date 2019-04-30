#!/usr/bin/ruby
require 'rubygems'

AwesomePrint.irb! if require 'awesome_print'

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

load File.dirname(__FILE__) + '/.railsrc' if $PROGRAM_NAME == 'irb' && ENV['RAILS_ENV']
