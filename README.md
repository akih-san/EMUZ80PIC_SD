# EMUZ80PIC_SD

EMUZ80PIC_SDは、EMUZ80にアドオンするμSDカードモジュールです。<br>
EMUZ80+SuperMEZ80、または、EMUZ80+MEZZ180RAMの組み合わせで、CP/M-80 Ver2.2を走らせることが出来ます。<br>
EMUZ80は、電脳伝説(@vintagechips)さんによって作成された2チップで動作するシンプルなSBCです。<br>
SuperMEZ80、MEZZ180RAMは、@S_Okueさんによって作成されたEMUZ80用のメザニンボードです。<br>
EMUZ80、SuperMEZ80、MEZZ180RAMは、オレンジピコショップでお求めになれます。<br>
https://store.shopping.yahoo.co.jp/orangepicoshop/<br>
<br>
![EMUZ80PIC_SD 1](Photo/P1020376.JPG)
![EMUZ80PIC_SD 2](Photo/P1020381.JPG)
![EMUZ80PIC_SD 3](Photo/233.png)
<br>
# SuperMEZ80 + EMUZ80PIC_SD
![SuperMEZ80 1](Photo/P1020386.JPG)
![SuperMEZ80 2](Photo/P1020392.JPG)
<br>
# MEZZ180RAM + EMUZ80PIC_SD
![MEZZ180 1](Photo/P1020394.JPG)
![MEZZ180 2](Photo/P1020397.JPG)
<br>
@hanyazouさんのファームウェアを、EMUZ80PIC_SD用にカスタマイズしてあります。<br>
<br>
＜＠hanyazouさんのソース＞<br>
https://github.com/hanyazou/SuperMEZ80/tree/mez80ram-cpm<br>
<br>
ソースのコンパイルは、マイクロチップ社の「MPLAB® X Integrated Development Environment (IDE)」<br>
で行っております。（MPLAB X IDE v6.10）コンパイラは、XC8を使用しています。
https://www.microchip.com/en-us/tools-resources/develop/mplab-x-ide<br>
<br>
Z80のアセンブラは、Macro Assembler AS V1.42を使用しています。<br>
http://john.ccac.rwth-aachen.de:8000/as/<br>
<br>
FatFsはR0.15を使用しています。<br>
＜FatFs - Generic FAT Filesystem Module＞<br>
http://elm-chan.org/fsw/ff/00index_e.html<br>
<br>
SDカード上のCP/Mイメージファイルの作成は、CpmtoolsGUIを利用しています。<br>
＜CpmtoolsGUI - neko Java Home Page＞<br>
http://star.gmobb.jp/koji/cgi/wiki.cgi?page=CpmtoolsGUI<br>
<br>
また、IPL, BOOT, BIOS等の修正で、毎回イメージファイルを作るのは面倒なので、<br>
バイナリーエディタ「xedit」を利用しています。ファイルをバイナリレベルで修正<br>
出来るので便利です。<br>
https://janus.blog.ss-blog.jp/2016-06-17<br>
<br>
（オリジナルのリンクが切れているようです）<br>
フリーソフト１００からもダウンロードできます。<br>
https://freesoft-100.com/pasokon/editor_binary.html<br>
<br>
# MEZZ180RAMボードをPICから64Kアクセス出来るように改造する
MEZZ180RAMボードに改造を加えることで、PIC側から64K空間をアクセス出来るようになります。<br>
![MEZZ180RAM改造 1](MEZZ180RAM64K改造写真.jpg)
![MEZZ180RAM改造 2](MEZZ180RAM64K改造.jpg)
<br>
改造の施術を行ったら、cmp2ディレクトリにあるDRIVEA_64k.DSKをDRIVEAにリネームして、<br>
CPMDISKSディレクトリにコピーしてください。<br>
ブートイメージは、IOバイト転送、32K_DMA転送、64K_DMA転送のイメージファイルを用意してます。<br>
bios.asmのソースコードで確認してください<br>
<br>
次に、ファームウェアの修正ですが、src\boardsディレクトリ内のMEZ180_sd.cを修正します。<br>
////////////////////////////////<br>
// for remodeling MEZZ180RAM <br>
//#define PIC_64K<br>
////////////////////////////////<br>
<br>
38行目の#define PIC_64Kのコメントを外して、ファームをリビルドします。<br>
ビルドしたMEZ180SD_Q43.X\dist\default\production\MEZ180SD_Q43.X.production.hex<br>
をPICに書き込んで完成です。<br>
<br>
起動するとPIC側で64K認識するようになります。
<br>
詳細は、MEZ180_sd.cソースコードで確認してください。
<br>
# MEZZ180RAMボードの/RESETをプルダウンする
PICへの書き込みエラーの対策として、/RESETをプルダウンします。<br>
MEZZ180RAMと、EMUZ80PIC_SDを両方EMUZ80ボードに取り付けたままで、PICへファームウェアを<br>
書き込むと、かなりの高確率で書き込みエラーが発生します。PICを認識できないことも多いです。<br>
原因対策として、＠hanyazouさんが行っている/RESETをプルダウンする方法が非常に有効です。<br>
![reset_pulldown 1](reset_pulldown.png)
<br>
<br>
＜参考＞<br>
・EMUZ80<br>
EUMZ80はZ80CPUとPIC18F47Q43のDIP40ピンIC2つで構成されるシンプルなコンピュータです。<br>
<br>
＜電脳伝説 - EMUZ80が完成＞  <br>
https://vintagechips.wordpress.com/2022/03/05/emuz80_reference  <br>
＜EMUZ80専用プリント基板 - オレンジピコショップ＞  <br>
https://store.shopping.yahoo.co.jp/orangepicoshop/pico-a-051.html<br>
<br>
・SuperMEZ80<br>
SuperMEZ80は、EMUZ80にSRAMを追加し、Z80をノーウェイトで動かすことができるメザニンボードです<br>
<br>
SuperMEZ80<br>
https://github.com/satoshiokue/MEZ80RAM<br>
https://github.com/satoshiokue/SuperMEZ80<br>
<br>
・MEZZ180RAM<br>
MEZZ180RAMは、EMUZ80にZ180+SRAMのメザニンボードです。HD64180R/ZやZ8S180が動作します。<br>
<br>
MEZZ180RAM<br>
https://github.com/satoshiokue/MEZZ180RAM<br>
https://github.com/satoshiokue/EMUZ80-Z180RAM<br>
