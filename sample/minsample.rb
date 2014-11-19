# coding: utf-8
require 'dxruby'
require_relative '../lib/dxrubyws'
require_relative '../lib/standardgui'

WS.set_theme("guibasic")

Window.width, Window.height = 1280, 720 # ワイド画面化

# オブジェクトブラウザを作る実験
class WS::WSObjectBrowser < WS::WSWindow
  def initialize(tx, ty, width, height, caption, obj)
    super(tx, ty, width, height, caption)
    lbx = WS::WSListBox.new(10,10,150,100)
    self.client.add_control(lbx, :lbx)
    lbl1 = WS::WSLabel.new(0, 0, 100, 16, "SuperClass : ")
    lbl1.fore_color = C_BLACK
    self.client.add_control(lbl1, :lbl1)
    lbl2 = WS::WSLabel.new(0, 0, 200, 16)
    lbl2.fore_color = C_BLACK
    self.client.add_control(lbl2, :lbl2)

    titles = [["instance_variable", 100], ["class", 150], ["to_s", 200]]
    lv = WS::WSListView.new(50, 30, 100, 160, titles)
    self.instance_variables.each do |i|
      lv.items << [i, self.instance_variable_get(i).class, self.instance_variable_get(i)]
    end
    self.client.add_control(lv, :lv)

    add_key_handler(K_F5){redraw}

    client.layout(:vbox) do
      layout(:hbox) do
        self.height = lbl1.height
        self.resizable_height = false
        add lbl1, false
        add lbl2, false
        layout
      end
      layout(:hbox) do
        add lbx, false, true
        add lv, true, true
      end
    end
  end

  def redraw
    self.client.lv.items.clear
    self.instance_variables.each do |i|
      self.client.lv.items << [i, self.instance_variable_get(i).class, self.instance_variable_get(i)]
    end
  end

end

module UseObjectBrowser
  @@ary = []
  @@ary << WS::WSMenuItem.new("Browse it") do |obj|
    obj = obj.parent if WS::WSWindow::WSWindowClient == obj.class
    tmp = WS::WSObjectBrowser.new(Input.mouse_pos_x, Input.mouse_pos_y, 600, 200, "ObjectBrowser : " + obj.to_s, obj)
    tmp.client.lbl2.caption = obj.class.superclass.to_s
    WS.desktop.add_control(tmp)
  end
  def initialize(*args)
    super(*args)
    self.m_menuitems = @@ary
  end
end

class WS::WSWindowBase::WSWindowClient
  include UseObjectBrowser
  include WS::UseMiddleClickMenu
end

# ListBoxTestWindow
w = WS::WSWindow.new(400, 100, 200, 250, "ListBoxTest")
lbx = WS::WSListBox.new
lbx.items.concat(String.instance_methods(false))
#lbx.items.concat(w.instance_variables)
w.client.add_control(lbx)
txt = WS::WSTextBox.new(0, 0, 100, 20)
txt.text = lbx.items[lbx.cursor].to_s
lbx.add_handler(:select){|obj, cursor| txt.text = obj.items[cursor].to_s}
w.client.add_control(txt)

w.client.layout(:vbox) do
  add txt, true
  add lbx, true, true
end

WS::desktop.add_control(w)

# ポップアップメニューのデータ
submenu1 = []
submenu1 << WS::WSMenuItem.new("Add new Window1") do
  WS.desktop.add_control(WS::WSWindow.new(Input.mouse_pos_x, Input.mouse_pos_y, 300, 100, "PopupTestWindow1"))
end
submenu1 << WS::WSMenuItem.new("Add new Window2") do
  WS.desktop.add_control(WS::WSWindow.new(Input.mouse_pos_x, Input.mouse_pos_y, 300, 100, "PopupTestWindow2"))
end

submenu2 = []
submenu2 << WS::WSMenuItem.new("Add new Window3") do
  WS.desktop.add_control(WS::WSWindow.new(Input.mouse_pos_x, Input.mouse_pos_y, 300, 100, "PopupTestWindow3"))
end
submenu2 << WS::WSMenuItem.new("Add new Window4") do
  WS.desktop.add_control(WS::WSWindow.new(Input.mouse_pos_x, Input.mouse_pos_y, 300, 100, "PopupTestWindow4"))
end

submenu3 = []
submenu3 << WS::WSMenuItem.new("Add new Window5") do
  WS.desktop.add_control(WS::WSWindow.new(Input.mouse_pos_x, Input.mouse_pos_y, 300, 100, "PopupTestWindow5"))
end
submenu3 << WS::WSMenuItem.new("Add new Window6") do
  WS.desktop.add_control(WS::WSWindow.new(Input.mouse_pos_x, Input.mouse_pos_y, 300, 100, "PopupTestWindow6"))
end
submenu3 << WS::WSMenuItem.new("submenutest →", submenu2)

mainmenu = []
mainmenu << WS::WSMenuItem.new("Add new Object1 →", submenu1)
mainmenu << WS::WSMenuItem.new("Add new Object2 →", submenu3)
mainmenu << nil # nilが入っていたらセパレータラインが表示される
mainmenu << WS::WSMenuItem.new("Exit") do
  break
end

# ListViewTestWindow
w = WS::WSWindow.new(600, 100, 300, 200, "ListViewTest")
titles = [["instance_variable", 100], ["class", 150], ["to_s", 200]]
lv = WS::WSListView.new(50, 30, 100, 160, titles)
w.instance_variables.each do |i|
  lv.items << [i, w.instance_variable_get(i).class, w.instance_variable_get(i)]
end
w.client.add_control(lv)
w.add_menubar([["がおー", mainmenu], ["わおー", submenu1], ["うぎゃー", submenu2]])

w.client.layout(:vbox) do
  add lv, true, true
end

WS::desktop.add_control(w)


# LayoutTestWindow
class Test < WS::WSWindow
  def initialize
    super(100, 340, 300, 200, "LayoutTest")

    b1 = WS::WSButton.new(nil, nil, 100, nil, "btn1") # オートレイアウトで自動設定させる座標やサイズはnilでよい
#    b2 = WS::WSButton.new(0, 0, 100, 20, "btn2")
    b2 = WS::WSImageButton.new(nil, nil, Image.load('./image/enemyshot2.png'), nil, nil, "btn2")
    self.client.add_control(b1)
    self.client.add_control(b2)

    img = WS::WSImage.new(nil, nil, 100, nil)
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
    # widthやheightがnilになっている場合、自動的にresizable_width/resizable_heightがtrueになるので指定する必要がなくなった。
    # でもnilじゃなく値を入れたときにオートレイアウトさせたければ第2、第3引数を指定する必要がある。
    client.layout(:vbox) do
      self.margin_top = 10
      self.margin_bottom = 10
      layout(:hbox) do
        add b1
        add img
      end
      layout(:hbox) do
        self.margin_left = 10
        self.margin_right = 10
        self.margin_top = 10
        add b2
      end
      layout
    end
  end
end

t = Test.new
WS.desktop.add_control(t)


# デザイン定義と動作定義のコードを分けるサンプル

# フォーム定義(TestWindow1)
class TestWindow1 < WS::WSWindow
  attr_accessor :button1, :label1, :textbox1, :textbox2, :image1
  def initialize(*param)
    super
    @button1 = WS::WSButton.new(10, 10, 150, 20, "Show MessageBox")
    @label1 = WS::WSLabel.new(10, 50, 100, 20, "label")
    @textbox1 = WS::WSTextBox.new(70, 45, 200, 20)
#    @textbox2 = WS::WSTextBox.new(70, 80, 200, 20)
    @image1 = WS::WSImage.new(200, 10, 30, 30)
    @pulldown1 = WS::WSPullDownList.new(70, 80, 200, 20, ["てすと1","てすと2","テスト3"])

    self.client.add_control(@button1)
    self.client.add_control(@label1)
    self.client.add_control(@textbox1)
#    self.client.add_control(@textbox2)
    self.client.add_control(@image1)
    self.client.add_control(@pulldown1)

    @button1.add_handler(:click) {|obj, tx, ty|self.button1_click(tx, ty)}
    @image1.add_handler(:mouse_over){|obj|self.image1_mouse_over}
    @image1.add_handler(:mouse_out){|obj|self.image1_mouse_out}
    @image1.add_handler(:mouse_push){|obj, tx, ty|self.image1_mouse_push(tx, ty)}
    @image1.add_handler(:mouse_r_push){|obj, tx, ty|self.image1_mouse_r_push(tx, ty)}

    @chkbox = WS::WSCheckBox.new(10, 105, 200, "あいう")
    self.client.add_control(@chkbox)

    @radio1 = WS::WSRadioButton.new(10, 129, 200, ["テスト1","テスト2","テスト3"], 12)
    self.client.add_control(@radio1)

    init
  end
end

# アプリコード
class TestWindow1
  def init
    @image_white = Image.new(30, 30, C_WHITE)
    @image_black = Image.new(30, 30, C_BLACK)
    @image_red = Image.new(30, 30, C_RED)
    @image_blue = Image.new(30, 30, C_BLUE)
    @image1.image = @image_white
  end

  def image1_mouse_over
    @image1.image = @image_black
  end

  def image1_mouse_out
    @image1.image = @image_white
  end

  def image1_mouse_push(tx, ty)
    @image1.image = @image_red
  end

  def image1_mouse_r_push(tx, ty)
    @image1.image = @image_blue
  end

  def button1_click(tx, ty)
    WS.desktop.add_control(WS::WSMessageBox.new("MessageBoxTest", "メッセージボックステスト"))
  end
end

w = TestWindow1.new(100, 100, 300, 240, "Test")
WS.desktop.add_control(w)
w.button1.activate


# とりあえずの右クリックメニューテスト
# 仕様はこれから考える。

# extendでいつでもポップアップ機能を追加できる。menuitemsにWSMenuItemの配列をセットする。
WS.desktop.extend WS::UseRightClickMenu
WS.desktop.r_menuitems = mainmenu


WS.desktop.add_key_handler(K_ESCAPE) do break end

Window.loop do
  WS.update
  Window.caption = Window.get_load.to_s
end
