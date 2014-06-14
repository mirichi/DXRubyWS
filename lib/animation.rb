#coding: UTF-8

require 'dxruby'

###############################################################################
#How you use this is almost equal to AnimeSprite class.                       #
#(http://dxruby.sourceforge.jp/cgi-bin/hiki.cgi?AnimeSprite%A5%AF%A5%E9%A5%B9)#
#You only have to remenber to call not 'update' method,                       #
#but 'update_animation' method.                                               #
#                                                                             #
#Animation module has its module method 'update_animation'.                   #
#You can use this like Sprite class's 'update'.                               #
#                                                                             #
#There is an example at the end of this Gist.                                 #
###############################################################################

module Animation
  def self.update_animation(*args)
    args.flatten.each do |obj|
      obj.update_animation if obj.respond_to?(:update_animation)
    end
  end
  
  def self.clean(ary)
    ary.delete_if do |obj|
      if Array >= obj.class
        self.clean(obj)
        obj.empty?
      else
        bool = false
        bool ||= obj.vanished? if obj.respond_to?(:vanished?)
        bool ||= obj.disposed? if obj.respond_to?(:disposed?)
        bool ||= (obj == nil)
        bool
      end
    end
  end
  
  def self.included(klass)
    if RenderTarget >= klass
      klass.class_eval do
        def initialize(width, height, bgcolor=[0,0,0,0])
          super
          @animation_count = 0
          @animation_frame_count = 1
          @animation_pause = true
          @animation_animation_pattern = nil
          @animation_animation_image = []
          @animation_hash = {}
          @animation_next = nil
          @animation_running = ''
        end
        
        def update_animation
          if @animation_animation_pattern
            unless @animation_pause
              @animation_count += 1
              if @animation_count >= @animation_frame_count * @animation_animation_pattern.size
                if @animation_next
                  temp = @animation_hash[@animation_next]
                  if temp
                    @animation_frame_count = temp[0]
                    @animation_animation_pattern = temp[1]
                    @animation_next = temp[2]
                  else
                    self.send @animation_next
                  end
                end
                @animation_count = 0 
              end
            end
            self.draw(0,0,@animation_animation_image[@animation_animation_pattern[@animation_count / @animation_frame_count]],-10000)
          else
            unless @animation_pause
              @animation_count += 1
              if @animation_count >= @animation_frame_count * @animation_animation_image.size
                if @animation_next
                  temp = @animation_hash[@animation_next]
                  if temp
                    @animation_frame_count = temp[0]
                    @animation_animation_pattern = temp[1]
                    @animation_next = temp[2]
                  else
                    self.send @animation_next
                  end
                end
                @animation_count = 0
              end
            end
            self.draw(0,0,@animation_animation_image[@animation_count / @animation_frame_count],-10000)
          end
        end
        
        def animation_image=(v)
          @animation_animation_image = v
        end
      end
    elsif Sprite >= klass
      klass.class_eval do
        def initialize(x=0, y=0, image=nil)
          super
          @animation_count = 0
          @animation_frame_count = 1
          @animation_pause = true
          @animation_animation_pattern = nil
          @animation_animation_image = []
          @animation_hash = {}
          @animation_next = nil
          @animation_running = ''
        end
        
        def update_animation
          if @animation_animation_pattern
            unless @animation_pause
              @animation_count += 1
              if @animation_count >= @animation_frame_count * @animation_animation_pattern.size
                if @animation_next
                  temp = @animation_hash[@animation_next]
                  if temp
                    @animation_frame_count = temp[0]
                    @animation_animation_pattern = temp[1]
                    @animation_next = temp[2]
                  else
                    self.send @animation_next
                  end
                end
                @animation_count = 0 
              end
            end
            self.image = @animation_animation_image[@animation_animation_pattern[@animation_count / @animation_frame_count]]
          else
            unless @animation_pause
              @animation_count += 1
              if @animation_count >= @animation_frame_count * @animation_animation_image.size
                if @animation_next
                  temp = @animation_hash[@animation_next]
                  if temp
                    @animation_frame_count = temp[0]
                    @animation_animation_pattern = temp[1]
                    @animation_next = temp[2]
                  else
                    self.send @animation_next
                  end
                end
                @animation_count = 0
              end
            end
            self.image = @animation_animation_image[@animation_count / @animation_frame_count]
          end
        end
        
        def animation_image=(v)
          @animation_animation_image = v
          self.image = v[0]
        end
      end
    else
      raise ArgumentError, 'Include Animation:Module into RenderTarget, Sprite or their sub classes only!', caller(1) unless RenderTarget >= klass || Sprite >= klass
    end
  end
  
  def start_animation(v, animation_pattern=nil, nxt=nil)
    temp = @animation_hash[v]
    if temp
      @animation_running = v
      
      @animation_frame_count = temp[0]
      @animation_animation_pattern = temp[1]
      @animation_next = temp[2]
    else
      @animation_running = 'running'
      
      @animation_frame_count = v
      @animation_animation_pattern = animation_pattern
      @animation_next = nxt
    end
    @animation_pause = false
    @animation_count = 0 
  end

  def change_animation(v, animation_pattern=nil, nxt=nil)
    temp = @animation_hash[v]
    if temp
      @animation_running = v
      
      @animation_frame_count = temp[0]
      @animation_animation_pattern = temp[1]
      @animation_next = temp[2]
    else
      @animation_running = 'running'
      
      @animation_frame_count = v
      @animation_animation_pattern = animation_pattern
      @animation_next = nxt
    end
  end

  def pause_animation
    @animation_pause = true
  end

  def resume_animation
    @animation_pause = false
  end

  def add_animation(v, frame_count, animation_pattern=nil, nxt=nil)
    @animation_hash[v] = [frame_count, animation_pattern, nxt]
  end

  def animation_image
    @animation_animation_image
  end
  
  def inspect
    cname = self.class.name
    
    id = "0x" + self.object_id.to_s(16)
    
    status = (@animation_pause ? 'pause' : @animation_running.to_s)
    
    img_size = @animation_animation_image.size
    img_size = img_size.to_s + ' image' + (img_size >= 2 ? 's' : '')
    
    ptn_size = @animation_hash.size
    ptn_size = ptn_size.to_s + ' pattern' + (ptn_size >= 2 ? 's' : '')
    
    '#<' + cname + ':' + id + ' ' + status + ' (' + img_size + ', ' + ptn_size + ')>'
  end
end

class AnimeSprite < Sprite
  include Animation
end

class AnimationRenderTarget < RenderTarget
  include Animation
end
ART = AnimationRenderTarget

class Image
  def self.dispose(*args)
    args.each do |obj|
      if Array >= obj.class
        self.dispose(*obj) unless obj.empty?
      else
        bool = obj.respond_to?(:dispose)
        bool = bool && obj.disposed? if obj.respond_to?(:disposed?)
        obj.dispose if bool
      end
    end
    
    nil
  end
end

=begin
#適当なexample
as = AnimeSprite.new
as.animation_image = Array.new(64){|i| Image.new(100,100,[i * 4] * 3)}
as.start_animation(1, Array.new(64){|i| i})

art = ART.new(100,100)
art.animation_image = Array.new(64){|i| Image.new(100,100,[255 - i * 4] * 3)}
art.start_animation(1, Array.new(64){|i| i})

Window.loop{Animation.update_animation(as,art);as.draw;Window.draw(100,0,art)}
=end
