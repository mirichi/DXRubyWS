# coding: utf-8
require 'weakref'

# フォントキャッシュ
class RenderTarget
  @@font_cache = WeakRef.new({})

  def draw_font(x, y, str, font, hash)
    GC.disable
    color = hash[:color]
    color = C_WHITE unless color
    @@font_cache = WeakRef.new({}) unless @@font_cache.weakref_alive?
    if @@font_cache.has_key?(font)
      data1 = @@font_cache[font]
    else
      data1 = @@font_cache[font] = {}
    end
    if data1.has_key?(color)
      data2 = data1[color]
    else
      data2 = data1[color] = {}
    end

    unless data2.has_key?(str)
      width = font.get_width(str)
      return if width == 0
      data2[str] = Image.new(width, font.size).draw_font_ex(0, 0, str, font, color:color, aa:false)
    end
    self.draw(x, y, data2[str])
    GC.enable
  end
end
