# coding: utf-8
require 'dxruby'
require_relative '../lib/dxrubyws'
require_relative '../lib/standardgui'

Window.width, Window.height = 1280, 720 # ワイド画面化

# オブジェクトブラウザを作る実験
class WS::WSObjectBrowser < WS::WSWindow
  def initialize(tx, ty, width, height, caption, obj)
    super(tx, ty, width, height, caption)
    lbx1 = WS::WSListBox.new(10,10,100,100)
    lbx2 = WS::WSListBox.new(10,10,100,100)
    self.client.add_control(lbx1, :lbx1)
    self.client.add_control(lbx2, :lbx2)
    lbl1 = WS::WSLabel.new(0, 0, 100, 16, "SuperClass : ")
    lbl1.fore_color = C_BLACK
    self.client.add_control(lbl1, :lbl1)
    lbl2 = WS::WSLabel.new(0, 0, 200, 16)
    lbl2.fore_color = C_BLACK
    self.client.add_control(lbl2, :lbl2)

    obj.class.instance_methods(false).each do |s|
      lbx1.items << s
    end
    obj.instance_variables.each do |s|
      lbx2.items << s
    end

    client.layout(:vbox) do
      layout(:hbox) do
        self.height = lbl1.height
        self.resizable_height = false
        add lbl1, false
        add lbl2, false
        layout
      end
      layout(:hbox) do
        add lbx1, true, true
        add lbx2, true, true
      end
    end
  end
end

module UseObjectBrowser
  @@ary = []
  @@ary << WS::WSMenuItem.new("Browse it") do |obj|
    obj = obj.parent if WS::WSWindow::WSWindowClient == obj.class
    tmp = WS::WSObjectBrowser.new(Input.mouse_pos_x, Input.mouse_pos_y, 400, 200, "ObjectBrowser : " + obj.to_s, obj)
    tmp.client.lbl2.caption = obj.class.superclass.to_s
    WS.desktop.add_control(tmp)
  end
  def initialize(*args)
    super
    self.m_menuitems = @@ary
  end
end

class WS::WSWindow::WSWindowClient
  include UseObjectBrowser
  include WS::UseMiddleClickMenu
end
class WS::WSButton
  include UseObjectBrowser
  include WS::UseMiddleClickMenu
end
class WS::WSImage
  include UseObjectBrowser
  include WS::UseMiddleClickMenu
end



# TestWindow1
w = WS::WSWindow.new(100, 100, 300, 100, "Test")
b = WS::WSButton.new(10, 10, 100, 20, "button")
l = WS::WSLabel.new(10, 50, 100, 20, "label")
w.client.add_control(b)
w.client.add_control(l)

image1 = Image.new(30, 30, C_WHITE)
image2 = Image.new(30, 30, C_BLACK)
image3 = Image.new(30, 30, C_RED)
image4 = Image.new(30, 30, C_BLUE)
i = WS::WSImage.new(200, 30, 30, 30)
i.image = image1
i.add_handler(:mouse_over){|obj|obj.image = image2}
i.add_handler(:mouse_out){|obj|obj.image = image1}
i.add_handler(:mouse_push){|obj|obj.image = image3}
i.add_handler(:mouse_r_push){|obj|obj.image = image4}
w.client.add_control(i)

WS.desktop.add_control(w)

# ListBoxTestWindow
w = WS::WSWindow.new(400, 100, 200, 250, "ListBoxTest")
lbx = WS::WSListBox.new(50, 30, 100, 160)
lbx.items.concat(String.instance_methods(false))
#lbx.items.concat(w.instance_variables)
w.client.add_control(lbx)
lbl = WS::WSLabel.new(0, 0, 100, 16)
lbl.caption = lbx.items[lbx.cursor].to_s
lbx.add_handler(:select){|obj, cursor| lbl.caption = obj.items[cursor].to_s}
w.client.add_control(lbl)

w.client.layout(:vbox) do
  add lbl, true
  add lbx, true, true
end

WS::desktop.add_control(w)

# ListViewTestWindow
w = WS::WSWindow.new(600, 100, 300, 200, "ListViewTest")
titles = [["instance_variable", 100], ["class", 150], ["to_s", 200]]
lv = WS::WSListView.new(50, 30, 100, 160, titles)
w.instance_variables.each do |i|
  lv.items << [i, w.instance_variable_get(i).class, w.instance_variable_get(i)]
end
w.client.add_control(lv)

w.client.layout(:vbox) do
  add lv, true, true
end

WS::desktop.add_control(w)

# LayoutTestWindow
class Test < WS::WSWindow
  def initialize
    super(100, 300, 300, 200, "LayoutTest")

    b1 = WS::WSButton.new(0, 0, 100, 20, "btn1")
    b2 = WS::WSButton.new(0, 0, 100, 20, "btn2")
    self.client.add_control(b1)
    self.client.add_control(b2)

    img = WS::WSImage.new(0, 0, 100, 10)
    self.client.add_control(img)

    img.add_handler(:resize) do
      img.image.dispose if img.image
      img.image = Image.new(img.width, img.height, C_WHITE).circle_fill(img.width/2, img.height/2, img.width>img.height ? img.height/2 : img.width/2, C_GREEN)
    end

    # オートレイアウトのテスト
    # WSContainer#layoutでレイアウト定義を開始する。
    # 内部でLayoutオブジェクトを作成し、そのインスタンスでブロックがinstance_evalされる。
    # addメソッドはそのレイアウトボックス内にコントロールを追加する。
    # layoutの引数は:hboxと:vboxで、それぞれ水平配置、垂直配置となり、コントロールを並べてくれる。
    # WSContainer#layoutはコンテナ直下にレイアウトボックスを1つ作成する。
    # Layout#layoutはその位置に可変サイズのレイアウトボックスを作成する。
    
    # WSControl#resizable_width/resizable_heightがfalseのコントロールはサイズが変更されない。デフォルトはfalse。
    # trueになってるやつは下記ルールでサイズが変更される。
    # レイアウトボックス内にサイズ可変のものが無い場合：コントロールは均等の間隔で配置される。
    # ある場合：レイアウトボックスがすべて埋まるように、可変サイズのオブジェクトを大きくする。
    #           このとき、可変サイズのオブジェクトが複数あったらそれらすべてが同じサイズになるように調整される。

    # hbox(水平配置)のレイアウトボックス内にresizeble_height=trueのオブジェクトが存在した場合、
    # 縦サイズはレイアウトボックスのサイズまで拡大される。縦横逆の場合も同じ。

    # レイアウトボックスは縦横可変サイズのオブジェクトとして扱われ、
    # 引数なしのlayoutだけを配置すると空っぽの可変サイズオブジェクトとして動作する。

    # self.margin_top=/left=/bottom=/right=でレイアウトボックスのマージンを設定できる。
    # self.をつけないとローカル変数への代入とみなされてしまうらしい。

    # addメソッドの第2、第3引数でそれぞれresizable_width/resizable_heightを指定できるようにした。
    client.layout(:vbox) do
      self.margin_top = 10
      self.margin_bottom = 10
      layout(:hbox) do
        add b1, false, true
        add img, false, true
      end
      layout(:hbox) do
        self.margin_left = 10
        self.margin_right = 10
        self.margin_top = 10
        add b2, true, true
      end
      layout
    end
  end
end

t = Test.new
WS.desktop.add_control(t)


# とりあえずの右クリックメニューテスト
# 仕様はこれから考える。
ary = []
ary << WS::WSMenuItem.new("Add new Window") do
  WS.desktop.add_control(WS::WSWindow.new(Input.mouse_pos_x, Input.mouse_pos_y, 300, 100, "PopupTestWindow"))
end
ary << nil # nilが入っていたらセパレータラインが表示される
ary << WS::WSMenuItem.new("Exit") do
  break
end

# extendでいつでもポップアップ機能を追加できる。menuitemsにWSMenuItemの配列をセットする。
WS.desktop.extend WS::UseRightClickMenu
WS.desktop.r_menuitems = ary

Window.loop do
  WS.update
  break if Input.key_push?(K_ESCAPE)
end
