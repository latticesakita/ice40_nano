[English version is available here → README_en.md](README_en.md)

# iCE40_nano

Lattice Propel を使用して RISC-V プロセッサ(nano core)を iCE40 Ultra Plus FPGA に実装したプロジェクトです。

---

## 🚀 プロジェクト概要

このプロジェクトは、低消費電力・小型 FPGA である **iCE40 Ultra Plus** 上に、RISC-V ベースの SoC を構築することを目的としています。Lattice Propel を活用して、ハードウェア設計とソフトウェア開発を統合的に行っています。参考までにイメージセンサーの初期化ルーチンを含んでいます。
iCE40_nano プロジェクトは性能よりも小型を目指したものです。iCE40_SM project と比較すると性能は劣りますが、使用するリソースは約 800 LUTs 小さく構成されており、他のカスタムロジックを追加しやすくなっています。

---

## 🔧 使用技術

- FPGA: Lattice iCE40 Ultra Plus  
- 開発ツール:
  - Lattice Propel（Builder: `ice40_nano.sbx`）
  - Lattice Radiant（Project: `ice40_nano.rdf`）
- プロセッサ: RISC-V  
- HDL: Verilog
- iCE40UP の Hardend IP を RISC-V からアクセス
- iCE40UP の SPSRAM 上で RISC-V が動作 
- IP パッケージ: `.ipk`（Propel の `ippack` を使用）

---

## 📦 カスタム IP

このプロジェクトでは、Propel に含まれる `ippack` ツールを使用して、独自の IP を作成・パッケージ化しています。

- IP フォルダ: `IP/`
- 主な IP:
  - `ahb_spsram_nano`
  - `gpio_ahbl`
  - `timer_ahbl`
  - `uart_ahbl`

---

## 📁 ディレクトリ構成

- iCE40_SM/
  - dpram1024x8/
  - dpram2048x2_512x8/
  - ice40_nano/
    - ice40_common/
    - lib/
      - IPs/
      - latticesemi.com/
      - personal/
  - IP/
    - ahb_spsram_nano/
    - gpio_ahbl/
    - timer_ahbl/
    - uart_ahbl/
  - ws/
  - sge/
  - tb/
  - verification/
  - impl_1/
---

## 🛠️ ビルド方法
システム上にPythonをインストールしてください。
Propel で生成される mem file を Binary file へ変換しています。

1. C ソースの編集は、Lattice Propel を起動し、`ws` を開く
2. Post build で mem file は tb フォルダへ自動的にコピーされる。
3. Radiant から tb/tb.spf スクリプトを実行するとシミュレーションを実行できる
4. Propel Builder を起動し ice40_nano/ice40_nano.sbx を読み込む
5. Builder で変更を行った場合、Builder から Radiant を起動すれば、Builder での変更が反映される。
6. SPI Flash への書き込み
7. Address: 0x000000 に impl_1/ice40_sm_impl_1.bin
8. Address: 0x030000 に propel_ws/ice40_nano/Debug/ice40_nano_Code_BE.bin

ターゲットとしている評価ボードは Upduino ボードです

---
## 📄 ライセンス

各ソースに書かれてあるライセンスを参照してください。

---

## 🙋‍♂️ 貢献

Issue や Pull Request は歓迎です。お気軽にどうぞ！
