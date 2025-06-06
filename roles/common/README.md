ロールの役割
=========
Linux共通設定

前提環境
------------
OSのインストールが完了してSSH接続可能である
作業は全てsudo実行可能な管理ユーザーで実施

手動手順書
----------------

## ユーザー環境変数の設定

管理ユーザーのホームディレクトリにディレクトリを作成

```bash
mkdir -pv ~/.bin
mkdir -pv ~/.work.d
mkdir -pv ~/backup.d
```

システムのホームディレクトリ共有設定にも同じものを作成

```bash
sudo mkdir -pv /etc/skel/.bin
sudo mkdir -pv /etc/skel/.work.d
```

### 環境変数を読み込むようにする。


事前に用意しておいた環境変数ファイル類を所定のディレクトリに格納
> **.bin**が環境変数ファイル、**.work.d**が運用スクリプト

## 運用スクリプト

**.work.d**ディレクトリに事前に用意しておいたスクリプトを設定




## 日本語環境をインストール
sudo apt -y install language-pack-ja-base language-pack-ja ibus-mozc 

### システム文字セットを日本語へ変更
sudo localectl set-locale LANG=ja_JP.UTF-8 LANGUAGE="ja_JP:ja" 
localectl
#***************
   System Locale: LANG=ja_JP.UTF-8
                  LANGUAGE=ja_JP:ja
       VC Keymap: n/a
      X11 Layout: n/a
       X11 Model: pc105
#***************

# 更新して変更を確認
source /etc/default/locale 
echo $LANG
#******
ja_JP.UTF-8
#******

## 時刻同期設定

時刻同期を行います。
パッケージをインストール

### NTPサーバ（chrony）のインストール

Ubuntu 20 LTS

```bash
sudo apt install chrony -y
```

CentOS8(RHEL8)

```bash
sudo dnf install chrony -y
```

### 時刻同期の上位サーバの設定

国内のNTPサーバを参照先に変更する。

まずは設定ファイルをバックアップ
```bash Ubuntu
cp -iv /etc/chrony/chrony.conf ~/backup.d/chrony.conf.org
```
```bash RHEL
cp -iv /etc/chrony.conf ~/backup.d/chrony.conf.org
```

バックアップを確認

```bash
ls -l ~/backup.d
```

設定を編集

```bash Ubuntu
sudo vi /etc/chrony/chrony.conf
```
```bash RHEL
sudo vi /etc/chrony.conf
```

編集した差分を確認

```bash Ubuntu
diff -usb /etc/chrony/chrony.conf ~/backup.d/chrony.conf.org
```
```bash RHEL
diff -usb /etc/chrony.conf ~/backup.d/chrony.conf.org
```

編集差分

```bash
--- /etc/chrony.conf    2021-09-04 12:58:17.850092575 +0900
+++ /home/daath/backup.d/chrony.conf.org        2021-09-04 11:59:42.730201215 +0900
@@ -1,8 +1,6 @@
 # Use public servers from the pool.ntp.org project.
 # Please consider joining the pool (http://www.pool.ntp.org/join.html).
-#pool 2.rhel.pool.ntp.org iburst
-pool ntp.nict.jp iburst
-pool ntp.jst.mfeed.ad.jp iburst
+pool 2.rhel.pool.ntp.org iburst

 # Record the rate at which the system clock gains/losses time.
 driftfile /var/lib/chrony/drift
```

サービス再起動して設定を反映

```bash
sudo systemctl restart chronyd
```

上位サーバとの接続状況を確認

```bsah
chronyc sources 
```

## ディストリビューション個別の設定

ディストリビューションごとの専用設定を行う

### RedHat

EPELパッケージをインストール

```bash
sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm 
```

リポジトリを確認

```bash
sudo yum repolist all | grep -i epel
```















