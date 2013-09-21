DXRubyWS(DXRuby1.5.6dev用)
========

## 概要

DXRubyWSはDXRuby上で動作するウィンドウシステムです。とはいえDXRubyはゲーム用ライブラリであるわけで、一般的に言うツールキットなどのような用途に使う本格的なものは目指していません。DXRubyWSはDXRubyで作られたゲームにGUIを追加するような場合の基本部分を提供することを狙っています。狙っているだけでほんとにそれができるかどうかはわかりません。

## 基本アーキテクチャ

よくある感じのコントロール(WSControl)とコンテナ(WSContainer)でオブジェクトツリーを構築するアーキテクチャです。クラス階層のトップはWSControlで、WSContainerはWSControlを継承しています。WSControlはDXRubyのSpriteを継承しているので、描画やクリック判定はその機能を使います。  
名前空間としてWSモジュールを定義してあり、毎フレームWS.updateを呼ぶことでウィンドウシステムの処理がされます。WS.update内でマウスの判定や描画処理がされますので、そこからのメソッド発行を受けて各種オブジェクトが動作します。  
システム側が発行するのはマウス関連だけですが(増えるかもしれません)、オブジェクトが各種条件によって発行するイベントとしてシグナル発行の仕組みがあります。シグナルの種類別に呼び出す処理を設定できるので、これでたとえばOKボタンを押した処理などを簡単に書くことができます。  
DXRubyWSの機能はこれだけで、これらとDXRubyの機能を使って比較的簡単に自由にGUIを構築できます。

## 夢

ウィンドウをいくつ作ってもCRubyの世界では単一のVMインスタンスで動作していますので、どのウィンドウでもRuby内のすべてのオブジェクトを参照することができます。これを利用して、Rubyの世界を可視化して、すべてのオブジェクトをマウスでつかみ、画面にグラフィカルに表示し、書き換えることができるようなものを作ってみたいと考えています。まあ、夢です。  

## その他

いまのところかなり実験的な実装になっています。仕様変更の可能性も高いと思っていますが、逆に仕様変更を提案するIssueやPullRequestなどもお待ちしております。新しいコントロールの実装や、コードの書き直し、機能追加、もっと便利なものに置き換えなどもてぐすねひいてお待ちしております。よろしくおねがいします。  
