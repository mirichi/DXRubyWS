# coding: utf-8
module WS
  ### 色定数 ###
  COLOR = {}
  COLOR[:base] = [190, 190, 190]         # ウィンドウやボタン等の基本色
  COLOR[:border] = [80, 80, 80]          # 外枠の色
  COLOR[:shadow] = [120,120,120]         # 影
  COLOR[:darkshadow] = [80,80,80]        # 濃い影
  COLOR[:light] = [220,220,220]          # 明るい
  COLOR[:highlight] = [240,240,240]      # ハイライト
  COLOR[:background] = [255,255,255]     # テキストボックス、リストボックスなどの背景色
  COLOR[:marker] = [0,0,0]               # チェックボックス、ラジオボタン等のマークの色
  COLOR[:select] = [0,30,153]            # リストボックスなどの選択色
  COLOR[:font] = [0,0,0]                 # デフォルトの文字色
  COLOR[:font_reverse] = [255, 255, 255] # 反転文字色
  COLOR[:windowtitle_font] = [255, 255, 255]
  COLOR[:mouse_over] = [0, 128, 192]
  # 画像キャッシュ用ハッシュ
  IMG_CACHE    = {}
end

module Window
  def self.draw_box(x1, y1, x2, y2, c, z=0)
    self.draw_line(x1, y1, x2, y1, c, z)
    self.draw_line(x2, y1, x2, y2, c, z)
    self.draw_line(x2, y2, x1, y2, c, z)
    self.draw_line(x1, y2, x1, y1, c, z)
  end
end

class RenderTarget
  def draw_box(x1, y1, x2, y2, c, z=0)
    self.draw_line(x1, y1, x2, y1, c, z)
    self.draw_line(x2, y1, x2, y2, c, z)
    self.draw_line(x2, y2, x1, y2, c, z)
    self.draw_line(x1, y2, x1, y1, c, z)
  end
end

class Image
  def draw_border(flag)
    if flag
      self.line(0,0,width-1,0,WS::COLOR[:highlight])
      self.line(0,0,0,height-1,WS::COLOR[:highlight])
      self.line(1,1,width-1,1,WS::COLOR[:light])
      self.line(1,1,1,height-1,WS::COLOR[:light])
      self.line(width-1,0,width-1,height-1,WS::COLOR[:darkshadow])
      self.line(0,height-1,width-1,height-1,WS::COLOR[:darkshadow])
      self.line(width-2,1,width-2,height-2,WS::COLOR[:shadow])
      self.line(1,height-2,width-2,height-2,WS::COLOR[:shadow])
    else
      self.line(0,0,width-1,0,WS::COLOR[:darkshadow])
      self.line(0,0,0,height-1,WS::COLOR[:darkshadow])
      self.line(1,1,width-1,1,WS::COLOR[:shadow])
      self.line(1,1,1,height-1,WS::COLOR[:shadow])
      self.line(width-1,0,width-1,height-1,WS::COLOR[:light])
      self.line(0,height-1,width-1,height-1,WS::COLOR[:light])
      self.line(width-2,1,width-2,height-2,WS::COLOR[:highlight])
      self.line(1,height-2,width-2,height-2,WS::COLOR[:highlight])
    end
  end
end

#元々の文字列を、指定したfontで、max_width以下にギリギリ収まるように短くする
#flagにfalseを指定すると、文字列の末尾の方を返す。
class String
  def within(font, max_width, flag = true)
    str = ""
    self.size.times do |i|
      if flag
        return str if font.getWidth(str + self[i]) > max_width
        str += self[i]
      else
        return str if font.getWidth(self[self.size - i - 1] + str) > max_width
        str = self[self.size - i - 1] + str
      end
    end
    return self
  end
end
