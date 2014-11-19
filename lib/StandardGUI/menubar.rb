    def hbox # 水平に並べる
      # サイズ未定のものをカウント
      undef_size_count = @data.count{|o| o.resizable_width}

      # サイズ確定オブジェクトのサイズ合計
      total = @data.inject(0){|t, o| t += (o.resizable_width ? 0 : o.width)}

      # サイズが確定されていないオブジェクトの配列作成
      undef_size_ctl = @data.select{|o| o.resizable_width}.sort_by{|o|o.min_width}.reverse

      width = 0
      rest = (self.width - @margin_left - @margin_right - total).to_f
      count = undef_size_ctl.size

      # サイズの大きいほうから残りのすべてをmin_widthにできるかどうかを確認する
      undef_size_ctl.each do |o|
        if rest < (count * o.min_width) # 入りきらない
          rest -= o.min_width # このぶんは確定とする
          count -= 1
        else
          width = rest / count
          break
        end
      end

      # 座標開始位置
      point = self.x + @margin_left

      case undef_size_count
      when 0 # 均等
        # 座標調整
        adjust_x do |o|
          tmp = (self.width - @margin_left - @margin_right - total) / (@data.size + 1) # オブジェクトの間隔を足す
          point += (tmp > 0 ? tmp : 0)
          @new_x = point
          point += @new_width
        end

      else # 最大化するものを含む
        # 座標調整
        adjust_x do |o|
          @new_x = point
          if o.resizable_width # 最大化するオブジェクトを最大化
            @new_width = (width < @new_min_width ? @new_min_width : width)
          end
          point += @new_width
        end
      end
    end
    
    def vbox # 垂直に並べる
      # サイズ未定のものをカウント
      undef_size_count = @data.count{|o| o.resizable_height}

      # サイズ確定オブジェクトのサイズ合計
      total = @data.inject(0){|t, o| t += (o.resizable_height ? 0 : o.height)}

      # サイズが確定されていないオブジェクトの配列作成
      undef_size_ctl = @data.select{|o| o.resizable_height}.sort_by{|o|o.min_height}.reverse

      height = 0
      rest = (self.height - @margin_top - @margin_bottom - total).to_f
      count = undef_size_ctl.size

      # サイズの大きいほうから残りのすべてをmin_heightにできるかどうかを確認する
      undef_size_ctl.each do |o|
        if rest < (count * o.min_height) # 入りきらない
          rest -= o.min_height # このぶんは確定とする
          count -= 1
        else
          height = rest / count
          break
        end
      end

      # 座標開始位置
      point = self.y + @margin_top

      case undef_size_count
      when 0 # 均等
        # 座標調整
        adjust_y do |o|
          tmp = (self.height - @margin_top - @margin_bottom - total) / (@data.size + 1) # オブジェクトの間隔を足す
          point += (tmp > 0 ? tmp : 0)
          @new_y = point
          point += @new_height
        end

      else # 最大化するものを含む
        # 座標調整
        adjust_y do |o|
          @new_y = point
          if o.resizable_height # 最大化するオブジェクトを最大化
            @new_height = (height < @new_min_height ? @new_min_height : height)
          end
          point += @new_height
        end
      end
    end
    
    def hbox_ex #水平に並べ、はみ出したら下の段に
      rest = default_rest = self.width - @margin_left - @margin_right
      lines = [[]]
      
      @data.each do |ctl|
        w = (ctl.resizable_width ? ctl.min_width : ctl.width)
        
        rest -= w
        if rest <= 0
          if lines[-1].empty?
            lines[-1] << ctl
            lines << []
          else
            lines << [ctl]
          end
          
          rest = default_rest - w
        else
          lines[-1] << ctl
        end
      end
      
      lines.delete([])
      
      lines.map! do |ary|
        WSLayout.new(:hbox, @obj, self) do
          ary.each do |ctl|
            add ctl
          end
        end
      end
      @min_height = lines.map(&:min_height).inject(&:+)
      @min_width = lines.map(&:min_width).max
      
      @data = lines
      
      vbox
    end
    
    def vbox_ex #上下に並べ、はみ出したら左の段へ
      rest = default_rest = self.height - @margin_top - @margin_bottom
      lines = [[]]
      
      @data.each do |ctl|
        w = (ctl.resizable_height ? ctl.min_height : ctl.height)
        
        rest -= w
        if rest <= 0
          if lines[0].empty?
            lines[0] << ctl
            lines.unshift []
          else
            lines.unshift [ctl]
          end
          
          rest = default_rest - w
        else
          lines[0] << ctl
        end
      end
      
      lines.delete([])
      
      lines.map! do |ary|
        WSLayout.new(:vbox, @obj, self) do
          ary.each do |ctl|
            add ctl
          end
        end
      end
      @min_width = lines.map(&:min_width).inject(&:+)
      @min_height = lines.map(&:min_height).max
      
      @data = lines
      
      hbox
    end
    
    def left #左に詰める
      point = self.x + @margin_left
      
      adjust_x do |o|
        @new_x = point
        @new_width = @new_min_width if o.resizable_width
        point += @new_width
      end
    end
    
    def right #右に詰める
      total = @data.map{|ctl| ctl.resizable_width ? ctl.min_width : ctl.width}.inject(&:+)
      
      point = self.x + self.width - @margin_right - total
      
      adjust_x do |o|
        @new_x = point
        @new_width = (o.resizable_width ? o.min_width : o.width)
        point += @new_width
      end
    end
    
    def hcenter #左右に並べ、中央に固める
      total = @data.map{|ctl| ctl.resizable_width ? ctl.min_width : ctl.width}.inject(&:+)
      
      point = self.x + (self.width + @margin_left - @margin_right - total) / 2
      
      adjust_x do |o|
        @new_x = point
        @new_width = (o.resizable_width ? o.min_width : o.width)
        point += @new_width
      end
    end
    
    def top #上に詰める
      point = self.y + @margin_top
      
      adjust_y do |o|
        @new_y = point
        @new_height = @new_min_height if o.resizable_height
        point += @new_height
      end
    end
    
    def bottom #下に詰める
      total = @data.map{|ctl| ctl.resizable_height ? ctl.min_height : ctl.height}.inject(&:+)
      
      point = self.y + self.height - @margin_bottom - total
      
      adjust_y do |o|
        @new_y = point
        @new_height = (o.resizable_height ? o.min_height : o.height)
        point += @new_height
      end
    end
    
    def vcenter #上下に並べ、中央に固める
      total = @data.map{|ctl| ctl.resizable_height ? ctl.min_height : ctl.height}.inject(&:+)
      
      point = self.y + (self.height + @margin_top - @margin_bottom - total) / 2
      
      adjust_y do |o|
        @new_y = point
        @new_height = (o.resizable_height ? o.min_height : o.height)
        point += @new_height
      end
    end
    
    def left_ex #左に詰め、はみ出したら下の段へ
      rest = default_rest = self.width - @margin_left - @margin_right
      lines = [[]]
      
      @data.each do |ctl|
        w = (ctl.resizable_width ? ctl.min_width : ctl.width)
        
        rest -= w
        if rest <= 0
          if lines[-1].empty?
            lines[-1] << ctl
            lines << []
          else
            lines << [ctl]
          end
          
          rest = default_rest - w
        else
          lines[-1] << ctl
        end
      end
      
      lines.delete([])
      
      lines.map! do |ary|
        WSLayout.new(:left, @obj, self) do
          ary.each do |ctl|
            add ctl
          end
        end
      end
      @min_height = lines.map(&:min_height).inject(&:+)
      @min_width = lines.map(&:min_width).max
      
      @data = lines
      
      vbox
    end
    
    def right_ex #右に詰め、はみ出したら下の段へ
      rest = default_rest = self.width - @margin_left - @margin_right
      lines = [[]]
      
      @data.each do |ctl|
        w = (ctl.resizable_width ? ctl.min_width : ctl.width)
        
        rest -= w
        if rest <= 0
          if lines[-1].empty?
            lines[-1] << ctl
            lines << []
          else
            lines << [ctl]
          end
          
          rest = default_rest - w
        else
          lines[-1] << ctl
        end
      end
      
      lines.delete([])
      
      lines.map! do |ary|
        WSLayout.new(:right, @obj, self) do
          ary.each do |ctl|
            add ctl
          end
        end
      end
      @min_height = lines.map(&:min_height).inject(&:+)
      @min_width = lines.map(&:min_width).max
      
      @data = lines
      
      vbox
    end
    
    def hcenter_ex #左右に並べ、中央に固める。はみ出したら下の段へ
      rest = default_rest = self.width - @margin_left - @margin_right
      lines = [[]]
      
      @data.each do |ctl|
        w = (ctl.resizable_width ? ctl.min_width : ctl.width)
        
        rest -= w
        if rest <= 0
          if lines[-1].empty?
            lines[-1] << ctl
            lines << []
          else
            lines << [ctl]
          end
          
          rest = default_rest - w
        else
          lines[-1] << ctl
        end
      end
      
      lines.delete([])
      
      lines.map! do |ary|
        WSLayout.new(:center, @obj, self) do
          ary.each do |ctl|
            add ctl
          end
        end
      end
      @min_height = lines.map(&:min_height).inject(&:+)
      @min_width = lines.map(&:min_width).max
      
      @data = lines
      
      vbox
    end
    
    def top_ex #上に詰め、はみ出したら左の段へ
      rest = default_rest = self.height - @margin_top - @margin_bottom
      lines = [[]]
      
      @data.each do |ctl|
        w = (ctl.resizable_height ? ctl.min_height : ctl.height)
        
        rest -= w
        if rest <= 0
          if lines[0].empty?
            lines[0] << ctl
            lines.unshift []
          else
            lines.unshift [ctl]
          end
          
          rest = default_rest - w
        else
          lines[0] << ctl
        end
      end
      
      lines.delete([])
      
      lines.map! do |ary|
        WSLayout.new(:top, @obj, self) do
          ary.each do |ctl|
            add ctl
          end
        end
      end
      @min_width = lines.map(&:min_width).inject(&:+)
      @min_height = lines.map(&:min_height).max
      
      @data = lines
      
      hbox
    end
    
    def bottom_ex #下に詰め、はみ出したら左の段へ
      rest = default_rest = self.height - @margin_top - @margin_bottom
      lines = [[]]
      
      @data.each do |ctl|
        w = (ctl.resizable_height ? ctl.min_height : ctl.height)
        
        rest -= w
        if rest <= 0
          if lines[0].empty?
            lines[0] << ctl
            lines.unshift []
          else
            lines.unshift [ctl]
          end
          
          rest = default_rest - w
        else
          lines[0] << ctl
        end
      end
      
      lines.delete([])
      
      lines.map! do |ary|
        WSLayout.new(:bottom, @obj, self) do
          ary.each do |ctl|
            add ctl
          end
        end
      end
      @min_width = lines.map(&:min_width).inject(&:+)
      @min_height = lines.map(&:min_height).max
      
      @data = lines
      
      hbox
    end
    
    def vcenter_ex #上下に並べ、中央に固める。はみ出したら左の段へ
      rest = default_rest = self.height - @margin_top - @margin_bottom
      lines = [[]]
      
      @data.each do |ctl|
        w = (ctl.resizable_height ? ctl.min_height : ctl.height)
        
        rest -= w
        if rest <= 0
          if lines[0].empty?
            lines[0] << ctl
            lines.unshift []
          else
            lines.unshift [ctl]
          end
          
          rest = default_rest - w
        else
          lines[0] << ctl
        end
      end
      
      lines.delete([])
      
      lines.map! do |ary|
        WSLayout.new(:vcenter, @obj, self) do
          ary.each do |ctl|
            add ctl
          end
        end
      end
      @min_width = lines.map(&:min_width).inject(&:+)
      @min_height = lines.map(&:min_height).max
      
      @data = lines
      
      hbox
    end
    
    def auto_layout
      @data = @default_data
      
      self.__send__(@type) if @@types.include?(@type)
