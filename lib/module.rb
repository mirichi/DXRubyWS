# coding: utf-8

# Mix-in用のモジュール
# いずれモジュール単位に分割するかもしれない。
# どれも結局マウスイベントを拾って判定・処理してシグナル投げるだけなので、
# ユーザレベルで作れないものはまったくない。

module WS
  # Windowsのボタンのようにマウスボタンを離した瞬間にself#on_clickを呼び出し、:clickシグナルを発行する
  # @image_flagがtrueのときにボタンは押した状態の絵を描画すること。
  module ButtonClickable
    def initialize(*args)
      super
      @pushed = false
    end
  
    def on_mouse_push(tx, ty)
      WS.capture(self)
      @pushed = true
      super
    end
  
    def on_mouse_release(tx, ty)
      @hit_cursor.x, @hit_cursor.y = tx + self.x, ty + self.y
      @pushed = false
      if @hit_cursor === self and WS.captured?(self)
        WS.capture(nil)
        on_click(tx, ty)
      else
        if WS.captured?(self)
          WS.capture(nil)
          on_click_cancel(tx, ty)
        else
          WS.capture(nil)
        end
      end
      super
    end
  
    def on_mouse_move(tx, ty)
      @hit_cursor.x, @hit_cursor.y = tx + self.x, ty + self.y
      if WS.captured?(self)
        @pushed = @hit_cursor === self
      end
      super
    end
  
    def on_click(tx, ty)
      signal(:click, tx, ty)
    end
  
    def on_click_cancel(tx, ty)
      signal(:click_cancel, tx, ty)
    end
  end

  # スクロールバーのボタンのようにオートリピートで:clickシグナルを発行し続ける
  # このシグナルはupdate時に発生する
  module RepeatClickable
    def initialize(*args)
      super
      @downcount = 0
      @pushed = false
    end
    def on_mouse_push(tx, ty)
      @old_tx, @old_ty = tx, ty
      WS.capture(self)
      @downcount = 20
      @pushed = true
      super
      on_click(tx, ty)
    end
  
    def on_mouse_release(tx, ty)
      @pushed = false
      WS.capture(nil)
      @downcount = 0
      super
    end
  
    def on_mouse_move(tx, ty)
      @hit_cursor.x, @hit_cursor.y = tx + self.x, ty + self.y
      if WS.captured?(self)
        @pushed = @hit_cursor === self
      end
      super
    end
  
    def update
      if @downcount > 0
        @downcount -= 1
        if @downcount == 0
          @downcount = 5
          on_click(@old_tx, @old_ty)
        end
      end
      super
    end
  
    def on_click(tx, ty)
      signal(:click, tx, ty)
    end
  end

  # マウスでドラッグしたときに:drag_moveシグナルを発行する
  # また、ボタン押したら:drag_start、離したら:drag_endを発行する
  # :drag_moveシグナルの引数は相対座標
  # インスタンス変数@dragging_flagを使う
  module Draggable
    def initialize(*args)
      super
      @dragging_flag = false
    end

    def on_mouse_push(tx, ty)
      @dragging_flag = true
      WS.capture(self)
      @drag_old_x = tx
      @drag_old_y = ty
      on_drag_start(tx, ty)
      super
    end

    def on_mouse_release(tx, ty)
      @dragging_flag = false
      WS.capture(nil)
      on_drag_end(tx, ty)
      super
    end

    def on_mouse_move(tx, ty)
      on_drag_move(tx - @drag_old_x, ty - @drag_old_y) if @dragging_flag
      super
    end

    def on_drag_move(tx, ty)
      signal(:drag_move, tx, ty)
    end

    def on_drag_start(tx, ty)
      signal(:drag_start, tx, ty)
    end

    def on_drag_end(tx, ty)
      signal(:drag_end, tx, ty)
    end
  end

  # オブジェクトのボーダーをつかんでサイズ変更したときにresizeメソッドを呼ぶ。
  # また、サイズ変更開始時にresize_start、終了時にresize_endメソッドを呼ぶ。
  # それらを呼んだあとで同名のシグナルを発行する。
  # マウスカーソルの見た目を変更する機能付き。
  # インスタンス変数@resize_top/@resize_left/@resize_right/@resize_bottomを使う
  module Resizable
    def on_mouse_push(tx, ty)
      if @resize_top or @resize_left or @resize_right or @resize_bottom
        WS.capture(self)
        @drag_old_x = tx
        @drag_old_y = ty
        resize_start
        signal(:resize_start)
      end
      super
    end

    def on_mouse_release(tx, ty)
      WS.capture(nil)
      Input.set_cursor(IDC_ARROW)
      resize_end
      signal(:resize_end)
      super
    end

    def on_mouse_move(tx, ty)
      if WS.captured?(self)
        x1, y1, width, height = self.x, self.y, self.width, self.height

        if @resize_left
          width += @drag_old_x - tx
          x1 += tx - @drag_old_x
          tx = @drag_old_x
          x1 -= (32 - width) if width < 32
        elsif @resize_right
          width += tx - @drag_old_x
          x1 = self.x if width < 32
        end
        if width >= 32
          @drag_old_x = tx
        else
           width = 32
        end

        if @resize_top
          height += @drag_old_y - ty
          y1 += ty - @drag_old_y
          ty = @drag_old_y
          y1 -= (32 - height) if height < 32
        elsif @resize_bottom
          height += ty - @drag_old_y
          y1 = self.y if height < 32
        end
        if height >= 32
          @drag_old_y = ty
        else
           height = 32
        end

        move(x1, y1)
        resize(width, height)
      else
        border_width = @border_width ? @border_width : 2
        @resize_top = ty < border_width
        @resize_left = tx < border_width
        @resize_right = self.width - tx <= border_width
        @resize_bottom = self.height - ty <= border_width
        case true
        when @resize_top
          case true
          when @resize_left
            Input.set_cursor(IDC_SIZENWSE)
          when @resize_right
            Input.set_cursor(IDC_SIZENESW)
          else
            Input.set_cursor(IDC_SIZENS)
          end
        when @resize_bottom
          case true
          when @resize_left
            Input.set_cursor(IDC_SIZENESW)
          when @resize_right
            Input.set_cursor(IDC_SIZENWSE)
          else
            Input.set_cursor(IDC_SIZENS)
          end
        when @resize_left
          Input.set_cursor(IDC_SIZEWE)
        when @resize_right
          Input.set_cursor(IDC_SIZEWE)
        else
          Input.set_cursor(IDC_ARROW)
        end
      end
      super
    end

    def on_mouse_out
      Input.set_cursor(IDC_ARROW)
      super
    end

    def resize_start
    end
    def resize_end
    end
  end

  # ダブルクリックしたときの2回目のボタン押下時に:doubleclickシグナルを発行する
  # インスタンス変数@doubleclickcout/@doubleclick_x/@doubleclick_yを使う
  # ダブルクリックの余裕は30フレーム/縦横5pixel以内で固定
  module DoubleClickable
    def on_mouse_push(tx, ty)
      if @doubleclickcount and @doubleclickcount > 0 and
         (@doubleclick_x - tx).abs < 5 and (@doubleclick_y - ty).abs < 5
          on_doubleclick(tx, ty)
      else
        @doubleclickcount = 30
        @doubleclick_x = tx
        @doubleclick_y = ty
      end
      super
    end

    def update
      @doubleclickcount -= 1 if @doubleclickcount and @doubleclickcount > 0
      super
    end

    def on_doubleclick(tx, ty)
      signal(:doubleclick, tx, ty)
    end
  end

  # フォーカスを受け取れるようにするモジュール
  module Focusable
    def initialize(*args)
      super
      @focusable = true
    end
  end

  # ウィンドウとして配下のコントロールにフォーカスを設定する機能をパッケージしたモジュール
  module WindowFocus
    # 配下のコントロールにフォーカスを設定する
    def mouse_event_dispatch(event, tx, ty)
      if event == :mouse_push or event == :mouse_r_push
        ctl = get_focusable_control(tx, ty)
        self.set_focus(ctl) if ctl
      end
      super
    end

    # ウィンドウを閉じたら次の優先ウィンドウにフォーカスを移す
    def close
      self.parent.remove_control(self)
      tmp = self.parent.childlen.last
      if tmp
        tmp.activate
      else
        WS.desktop.activate
      end
    end

    # キーハンドラを呼ばなかったらウィンドウフォーカスコントロールに転送
    def on_key_push(key)
      if @window_focus
        tmp = @window_focus.on_key_push(key)
        tmp = super unless tmp
        tmp
      else
        super
      end
    end

    # キーハンドラを呼ばなかったらウィンドウフォーカスコントロールに転送
    def on_key_release(key)
      if @window_focus
        tmp = @window_focus.on_key_release(key)
        tmp = super unless tmp
        tmp
      else
        super
      end
    end

    # ウィンドウ上のフォーカスがあるコントロールに文字列イベントを転送
    def on_string(str)
      @window_focus.on_string(str) if @window_focus
      super
    end

    # コントロールにウィンドウフォーカスを設定する
    def set_focus(obj)
      return nil if @window_focus == obj
      @window_focus.on_leave if self.activated? and  @window_focus
      @window_focus = obj
      @window_focus.on_enter if self.activated? and @window_focus
      obj
    end

    # ウィンドウがアクティブ化したときにフォーカスコントロールにon_enterを転送
    def on_enter
      @window_focus.on_enter if @window_focus
      super
    end

    # ウィンドウがノンアクティブ化したときにフォーカスコントロールにon_leaveを転送
    def on_leave
      @window_focus.on_leave if @window_focus
      super
    end
  end
  
  module HoverTextDisplayable
    
    #表示するテキストのクラス
    class HoverText < WSControl
      def initialize(text, font = nil, max_width = nil)
        super(0,0,0,0) #取り敢えず生成
        
        set_hover_text(text, font, max_width)
      end
      
      def set_hover_text(text, font, max_width)
        @old_text = text
        txt = text.gsub($/, "") #改行は不可能
        @font = font if font
        @max_width = max_width
        
        @text = []
        width = 0
        sum = 0
        length = txt.length
        
        until sum == length
          new_added = (max_width ? txt.within(@font, max_width) : txt)
          new_added = txt[0] if new_added.empty?
          @text << new_added
          txt = txt[(new_length = new_added.length)..-1]
          sum += new_length
          width = [width, @font.get_width(new_added)].max
        end
        
        self.width = width + 4
        self.height = @text.size * @font.size + 4
        
        self.image = Image.new(self.width, self.height, COLOR[:background])
                     .box(0,0,self.width-1,self.height-1,COLOR[:border])
        @text.each_with_index do |v, i|
          self.image.draw_font_ex(2, i * @font.size + 2, v, @font, color: COLOR[:font], aa: false)
        end
        
        @show = false
      end
      
      def text
        @text.join($/)
      end
      def text=(v)
        set_hover_text(v, @font, @max_width)
        v
      end
      
      def font
        @font
      end
      def font=(v)
        set_hover_text(@old_text, v, @max_width)
        v
      end
      
      def max_width
        @max_width
      end
      def max_width=(v)
        set_hover_text(@old_text, @font, v)
        v
      end
      
      def show(x, y)
        return if @show
        self.x = x
        self.y = y
        WS.desktop.add_control(self)
        @show = true
      end
      
      def hide
        return unless @show
        WS.desktop.remove_control(self)
        self.vanish
        @show = false
      end
    end
    
    def initialize(*args)
      super
      @hovertext_wait = 30
      @hovertext_frame = 120
      @hovertext = "default hovertext"
      @hovertext_frame_count = 0
      @hovertext_max_width = nil
    end
    
    def update
      super
      if @mouse_over
        if @hovertext_frame_count >= @hovertext_wait
          unless @hovertext_frame
            @hovertext_control ||= HoverText.new(@hovertext, @font, @hovertext_max_width)
            @hovertext_control.show(Input.mousePosX + 1, Input.mousePosY + 1)
          else
            if @hovertext_frame_count < @hovertext_wait + @hovertext_frame
              @hovertext_control ||= HoverText.new(@hovertext, @font, @hovertext_max_width)
              @hovertext_control.show(Input.mousePosX + 1, Input.mousePosY + 1)
            else
              @hovertext_control.hide
            end
          end
        end
        
        @hovertext_frame_count += 1
        
      else
        if @hovertext_control
          @hovertext_control.hide
          @hovertext_control = nil
        end
        @hovertext_frame_count = 0
      end
    end
    
    def hover_text
      @hovertext_control ? @hovertext_control.text : @hovertext
    end
    def hover_text=(v)
      @hovertext = v
      if @hovertext_control
        @hovertext_control.text = v
      end
    end
    
    def font=(v)
      super
      if @hovertext_control
        @hovertext_control.font = v
      end
    end
    
    def hover_text_max_width
      @hovertext_max_width
    end
    def hover_text_max_width=(v)
      @hovertext_max_width = v
      if @hovertext_control
        @hovertext_control.max_width = v
      end
    end
  end
  
end
