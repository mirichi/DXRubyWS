require 'dxruby'
require_relative './core'
require_relative './window'
require_relative './button.rb'
require_relative './label'
require_relative './image'
require_relative './listbox'

# ウィンドウシステム
module WS
  class WSDesktop < WSContainer
    attr_accessor :capture_object
    def initialize
      self.collision = [0, 0, Window.width - 1, Window.height - 1]
      @childlen = []
      @signal = {}
      @hit_cursor = Sprite.new
      @hit_cursor.collision = [0,0]
      @font = @@default_font
      @mouse_flag = false
      @capture_object = nil
      @over_object = nil
    end

    def add_control(obj, name=nil)
      super
      obj.z = WS.default_z
      obj.target = Window
    end

    def update
      oldx, oldy = @hit_cursor.x, @hit_cursor.y
      @hit_cursor.x, @hit_cursor.y = Input.mouse_pos_x, Input.mouse_pos_y
  
      # マウスカーソルの移動処理
      if oldx != @hit_cursor.x or oldy != @hit_cursor.y
        # キャプチャされていたら@captureのメソッドを呼ぶ
        old_over_object = @over_object
        if @capture_object
          tx, ty = @capture_object.get_global_vertex
          @over_object = @capture_object.on_mouse_move(@hit_cursor.x - tx, @hit_cursor.y - ty)
        else
          @over_object = self.on_mouse_move_internal(@hit_cursor.x, @hit_cursor.y)
        end
        if old_over_object != @over_object
          old_over_object.on_mouse_out if old_over_object
          @over_object.on_mouse_over
        end
      end
  
      # ボタン押した
      if Input.mouse_down?(M_LBUTTON) and @mouse_flag == false
        @mouse_flag = true
        self.on_mouse_down_internal(@hit_cursor.x, @hit_cursor.y, M_LBUTTON)
      end
  
      # ボタン離した。キャプチャされてたら@captureのメソッドを呼ぶ
      if !Input.mouse_down?(M_LBUTTON) and @mouse_flag == true
        @mouse_flag = false
        if @capture_object
          tx, ty = @capture_object.get_global_vertex
          @capture_object.on_mouse_up(@hit_cursor.x - tx, @hit_cursor.y - ty, M_LBUTTON)
        else
          self.on_mouse_up_internal(@hit_cursor.x, @hit_cursor.y, M_LBUTTON)
        end
      end

      super
    end
  end

  @@desktop = WSDesktop.new

  # ウィンドウシステムのメイン処理
  def self.update
    @@desktop.update
    @@desktop.draw
  end

  def self.capture(obj)
    @@desktop.capture_object = obj
  end

  def self.desktop
    @@desktop
  end

  def self.captured?(obj)
    @@desktop.capture_object == obj
  end

  @@default_z = 10000
  def self.default_z;@@default_z;end
  def self.default_z=(v);@@default_z=v;end
end
