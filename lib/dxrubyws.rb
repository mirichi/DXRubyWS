require 'dxruby'
require_relative './core'
require_relative './window'
require_relative './button.rb'
require_relative './label'
require_relative './image'

# ウィンドウシステム
module WS
  class WSDesktop < WSContainer
    def initialize
      super(0, 0, Window.width, Window.height)
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
      if @@capture
        tx, ty = @@capture.get_global_vertex
        @@over_object = @@capture.on_mouse_move(@@cursor.x - tx, @@cursor.y - ty)
      else
        @@over_object = @@desktop.on_mouse_move(@@cursor.x, @@cursor.y)
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

  def self.over_object
    @@over_object
  end
end

