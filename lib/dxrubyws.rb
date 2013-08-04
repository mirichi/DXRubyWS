require 'dxruby'
require_relative './core'
require_relative './window'
require_relative './button.rb'
require_relative './label'
require_relative './image'

# ウィンドウシステム
module WS
  class WSDesktop < WSContainer
    @@default_z = 10000
    def self.default_z;@@default_z;end
    def self.default_z=(v);@@default_z=v;end

    def initialize
      self.collision = [0, 0, Window.width, Window.height]
      @childlen = []
      @signal = {}
      @cursor = Sprite.new
      @cursor.collision = [0,0]
      @font = @@default_font
    end

    def add_control(obj)
      obj.z = @@default_z
      super
    end

    def draw
      Sprite.draw(@childlen)
    end
  end

  @@desktop = WSDesktop.new
  @@cursor = Sprite.new
  @@mouse_flag = false
  @@capture = nil
  @@over_object = nil

  # ウィンドウシステムのメイン処理
  def self.update
    oldx, oldy = @@cursor.x, @@cursor.y
    @@cursor.x, @@cursor.y = Input.mouse_pos_x, Input.mouse_pos_y

    # マウスカーソルの移動処理
    if oldx != @@cursor.x or oldy != @@cursor.y
      # キャプチャされていたら@@captureのメソッドを呼ぶ
      old_over_object = @@over_object
      if @@capture
        tx, ty = @@capture.get_global_vertex
        @@over_object = @@capture.mouse_move(@@cursor.x - tx, @@cursor.y - ty)
      else
        @@over_object = @@desktop.on_mouse_move(@@cursor.x, @@cursor.y)
      end
      if old_over_object != @@over_object
        old_over_object.mouse_out if old_over_object
        @@over_object.mouse_over
      end
    end

    # ボタン押した
    if Input.mouse_down?(M_LBUTTON) and @@mouse_flag == false
      @@mouse_flag = true
      @@desktop.on_mouse_down(@@cursor.x, @@cursor.y, M_LBUTTON)
    end

    # ボタン離した。キャプチャされてたら@@captureのメソッドを呼ぶ
    if !Input.mouse_down?(M_LBUTTON) and @@mouse_flag == true
      @@mouse_flag = false
      if @@capture
        tx, ty = @@capture.get_global_vertex
        @@capture.on_mouse_up(@@cursor.x - tx, @@cursor.y - ty, M_LBUTTON)
      else
        @@desktop.on_mouse_up(@@cursor.x, @@cursor.y, M_LBUTTON)
      end
    end

    Sprite.update @@desktop
    Sprite.draw @@desktop
  end

  def self.capture(obj)
    @@capture = obj
  end

  def self.desktop
    @@desktop
  end

  def self.captured?(obj)
    @@capture == obj
  end

end

