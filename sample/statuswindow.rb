# coding: utf-8
require 'dxruby'
require_relative '../lib/dxrubyws'
require_relative '../lib/standardgui'

WS.set_theme("guibasic")

Window.width, Window.height = 1280, 720 # ワイド画面化

module Game
  class Actor
    attr_accessor :name
    attr_accessor :maxhp
    attr_accessor :hp
    attr_accessor :maxmp
    attr_accessor :mp
    
    def initialize(name = "")
      @name = name
      @maxhp = rand(999)
      @hp = @maxhp
      @maxmp = rand(999)
      @mp = @maxmp
    end
  end
end

$game_actor = [Game::Actor.new("mirich"), Game::Actor.new("ハイド"), Game::Actor.new("なるみん")]

module WS
  class StatusWindow < WSWindow
    attr_reader :panel
    def initialize(x, y, width, height)
      super(x, y, width, height, "Status")
      create_status_panel
    end
    
    def create_status_panel
      @panel = []
      for i in 0..2
        @panel << StatusPanel.new($game_actor[i])
        client.add_control(@panel[i])
      end
      
      self.client.layout(:vbox) do
        set_margin(8,8,8,8)
        obj.parent.panel.each do |panel|
          add panel, true, false
        end
      end
      
    end
    
    class StatusPanel < WSContainer
      def initialize(actor)
        super(0, 0, 200, 80)
        @actor = actor
        create_controls
      end
      
      def set_actor
        @actor = actor
        refresh_status
      end
      
      def create_controls
        add_control(WSLabel.new(0, 0, 32, 20), :c_name)
        add_control(WSLabel.new(0, 0, 32, 20), :c_hp)
        add_control(WSLabel.new(0, 0, 32, 20), :c_mp)
        
        refresh_status
        
        layout(:vbox) do
          add obj.c_name, true, false
          add obj.c_hp,   true, false
          add obj.c_mp,   true, false
        end
      end
      
      def refresh_status
        c_name.caption = @actor.name
        c_hp.caption = sprintf("HP:%3d/%3d", @actor.hp, @actor.maxhp)
        c_mp.caption = sprintf("MP:%3d/%3d", @actor.mp, @actor.maxmp)
      end
    end
    
  end
end

WS.desktop.add_control(WS::StatusWindow.new(0, 0, 240, 360))

WS.desktop.add_key_handler(K_ESCAPE) do break end

Window.loop do
  WS.update
  Window.caption = Window.get_load.to_s
end
