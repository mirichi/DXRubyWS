require 'dxruby'
require_relative './module.rb'

module WS
  class WSImage < WSControl
    include Clickable
    include MouseOver
  end
end


