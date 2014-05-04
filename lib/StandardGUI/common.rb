# coding: utf-8
module WS
  ### 色定数 ###
  # 色名
  C_GRAY = [190, 190, 190]
  C_DARK_GRAY = [120,120,120]
  C_LIGHT_BLACK = [80,80,80]
  C_DARK_WHITE = [240,240,240]
  C_LIGHT_GRAY = [220,220,220]
  # パーツ名
  C_BASE = [190, 190, 190]               # ウィンドウやボタン等の基本色
  C_SHADOW = [120,120,120]               # 影
  C_DARKSHADOW = [80,80,80]              # 濃い影
  C_LIGHT = [220,220,220]                # 明るい
  C_HIGHLIGHT = [240,240,240]            # ハイライト
  C_CONTROL_BASE = [255,255,255]         # テキストボックス、リストボックスなどの背景色
  C_MARKER = [0,0,0]                     # チェックボックス、ラジオボタン等のマークの色
  C_SELECT = [0,30,153]                  # リストボックスなどの選択色
  C_FONT_COLOR = [0,0,0]                 # デフォルトの文字色
  C_FONT_REVERSE_COLOR = [255, 255, 255] # 反転文字色
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
      self.line(0,0,width-1,0,WS::C_HIGHLIGHT)
      self.line(0,0,0,height-1,WS::C_HIGHLIGHT)
      self.line(1,1,width-1,1,WS::C_LIGHT)
      self.line(1,1,1,height-1,WS::C_LIGHT)
      self.line(width-1,0,width-1,height-1,WS::C_DARKSHADOW)
      self.line(0,height-1,width-1,height-1,WS::C_DARKSHADOW)
      self.line(width-2,1,width-2,height-2,WS::C_SHADOW)
      self.line(1,height-2,width-2,height-2,WS::C_SHADOW)
    else
      self.line(0,0,width-1,0,WS::C_DARKSHADOW)
      self.line(0,0,0,height-1,WS::C_DARKSHADOW)
      self.line(1,1,width-1,1,WS::C_SHADOW)
      self.line(1,1,1,height-1,WS::C_SHADOW)
      self.line(width-1,0,width-1,height-1,WS::C_LIGHT)
      self.line(0,height-1,width-1,height-1,WS::C_LIGHT)
      self.line(width-2,1,width-2,height-2,WS::C_HIGHLIGHT)
      self.line(1,height-2,width-2,height-2,WS::C_HIGHLIGHT)
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
