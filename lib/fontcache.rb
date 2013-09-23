# coding: utf-8

# フォントキャッシュ
class RenderTarget

  def draw_font(x, y, str, font, hash)
    @@font_cache ||= {}
    color = hash[:color]
    color = C_WHITE unless color
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
      data2[str] = Image.new(width, font.size).draw_font(0, 0, str, font, color)
    end
    self.draw(x, y, data2[str])
  end
end
