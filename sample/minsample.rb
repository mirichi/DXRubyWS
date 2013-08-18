require 'dxruby'
require_relative '../lib/dxrubyws'

# TestWindow1
w = WS::WSWindow.new(100, 100, 300, 100, "Test")
b = WS::WSButton.new(10, 10, 100, 20)
l = WS::WSLabel.new(10, 50, 100, 20)
w.client.add_control(b)
w.client.add_control(l)

image1 = Image.new(30, 30, C_WHITE)
image2 = Image.new(30, 30, C_BLACK)
image3 = Image.new(30, 30, C_RED)
i = WS::WSImage.new(200, 30, 30, 30)
i.image = image1
i.add_handler(:mouse_over){|obj|obj.image = image2}
i.add_handler(:mouse_out){|obj|obj.image = image1}
i.add_handler(:click){|obj|obj.image = image3}
w.client.add_control(i)

WS.desktop.add_control(w)

# ListBoxTestWindow
w = WS::WSWindow.new(400, 100, 200, 250, "ListBoxTest")
lbx = WS::WSListBox.new(50, 30, 100, 160)
lbx.items.concat(String.instance_methods(false))
w.client.add_control(lbx)
lbl = WS::WSLabel.new(0, 0, 100, 16)
lbl.caption = lbx.items[lbx.cursor].to_s
lbx.add_handler(:select){|obj, cursor| lbl.caption = obj.items[cursor].to_s}
w.client.add_control(lbl)

w.layout(:vbox) do
  add lbl, true
  add lbx, true, true
end

WS::desktop.add_control(w)

# LayoutTestWindow
class Test < WS::WSWindow
  def initialize
    super(100, 300, 300, 100, "LayoutTest")
    self.image.bgcolor = [160,160,160]

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
    layout(:vbox) do
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

Window.loop do
  WS.update
  break if Input.key_push?(K_ESCAPE)
end

