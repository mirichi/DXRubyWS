module WS
  module ButtonClickable
    def initialize(tx=0, ty=0, image=nil)
      super
      @button_flag = false
    end

    def mouse_down(tx, ty, button)
      @button_flag = true
      WS.capture(self)
      super
    end

    def mouse_up(tx, ty, button)
      @button_flag = false
      WS.capture(nil)
      @cursor.x, @cursor.y = tx + self.x, ty + self.y
      signal(:click) if @cursor === self
      super
    end
  end
end
