# coding: utf-8

require_relative './common'

module WS
  class WSPullDownMenu < WSControl
    def initialize(tx, ty, width, height)
      super
      @content = []
      @image = Image.new(@width, @height, C_WHITE).draw_border(true)
    end
    
    def resize(width, height
      super
      @image.dispose if @image
      @image = @image.new(@width, @height, C_WHITE).draw_border(true)
    end
    
    def on_mouse_push(tx, ty)
      super
    end
    
    def draw
      super
    end
  end
end
