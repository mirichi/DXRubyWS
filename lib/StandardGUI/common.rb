# coding: utf-8
require 'dxruby'
module WS
  ### "動的な"定数 ###
  class DynamicConst
    def initialize(&block)
      @block = block
      def self.[](*args)
        @block.call(*args)
      end
    end
  end
  ### 色定数 ###
  COLOR = {}
  COLOR[:base] = [190, 190, 190]         # ウィンドウやボタン等の基本色
  COLOR[:shadow] = [120,120,120]         # 影
  COLOR[:darkshadow] = [80,80,80]        # 濃い影
  COLOR[:light] = [220,220,220]          # 明るい
  COLOR[:highlight] = [240,240,240]      # ハイライト
  COLOR[:background] = [255,255,255]     # テキストボックス、リストボックスなどの背景色
  COLOR[:marker] = [0,0,0]               # チェックボックス、ラジオボタン等のマークの色
  COLOR[:select] = [0,30,153]            # リストボックスなどの選択色
  COLOR[:font] = [0,0,0]                 # デフォルトの文字色
  COLOR[:font_reverse] = [255, 255, 255] # 反転文字色
  COLOR[:button] = DynamicConst.new do |float = 0.5|
    #float: buttonの一番上を0.0, 一番下を1.0としたFloat
    #buttonの一番上が明るさ222の灰色, 一番下が200の灰色
    [((200 * float + 222 * (1 - float)) * 255).div(240)] * 3 + [255]
  end
  #examle: COLOR[:button][0.3]
  COLOR[:border] = [112, 112, 112, 255]
  COLOR[:pushed] = [52, 180, 227]
  COLOR[:pushed_border] = [0, 137, 180]
  COLOR[:mouseover_border] = [38, 160, 218, 255]
  COLOR[:mouseover] = [166, 244, 255, 255]
  COLOR[:mark] = [255,0,0,255]
  
  # 画像キャッシュ用ハッシュ
  IMG_CACHE = {}
  IMG_CACHE[:dotted_box] = {}
  
  ### 画像定数 ###
  IMAGE = {}
  IMAGE[:dotted_box] = DynamicConst.new do |width, height, color|
    #キャッシュが有れば返す
    if having_key = (cache = IMG_CACHE[:dotted_box]).key?(width)
      if (cache_w = cache[width]).key?(height)
        next cache_w[height].dup
      end
    end
    
    #色を返すFiber
    f = Fiber.new{loop{3.times{Fiber.yield(color.size == 3 ? color + [255] : color)};3.times{Fiber.yield([0]*4)}}}
    
    ary = Array.new(height){Array.new(width){[0]*4}}
    #端を順に点線に
    (w_1 = width - 1).times{|x| ary[0][x] = f.resume}
    (h_1 = height - 1).times{|y| ary[y][w_1] = f.resume}
    w_1.times{|x| ary[h_1][w_1 - x] = f.resume}
    h_1.times{|y| ary[h_1 - y][0] = f.resume}
    
    #cache準備
    IMG_CACHE[:dotted_box][width] = {} unless having_key
    
    IMG_CACHE[:dotted_box][width][height] = Image.createFromArray(width, height, ary.flatten)
  end
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
