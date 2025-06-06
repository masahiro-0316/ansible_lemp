Role Name
=========

PHP-FPMインストール

Requirements
------------


PHPとPHPインストールを行う。
インストール後にPHPのエラーレポートとログ出力、ロケーション設定を行う

Role Variables
--------------

- php 7.4

Dependencies
------------

なし

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: php_fpm. tag: role_php }

License
-------

BSD

Author Information
------------------

An optional section for the role authors to include contact information, or a website (HTML is not allowed).


マニュアル設定手順
--------------

Rocky 8へのインストールの手動手順を記載


1. パッケージインストール

PHPパッケージリストを確認

```bash
sudo dnf module list php
```

他のバージョンが有効であればリセットして`8.0`を有効にする。

```bash
sudo dnf module reset php 
sudo dnf module enable php:8.0 -y
```

7.4を明示的にインストールする。

```bash
sudo dnf module -y install php:8.0/common
```

インストールを確認する。

```bash
php -v
php-fpm -v
```

1. 初期設定


PHP設定の修正を実施

```bash
mkdir -pv ~/backup.d/php-fpm/
cp -iv /etc/php.ini ~/backup.d/php-fpm/
sudo vi /etc/php.ini
```

差分を確認
```bash
diff -usb /etc/php.ini ~/backup.d/php-fpm/php.ini
```
```bash
--- /etc/php.ini        2024-03-17 08:47:44.945966801 +0900
+++ /home/daath/backup.d/php-fpm/php.ini        2024-03-17 08:44:24.066707652 +0900
@@ -483,7 +483,7 @@
 ; Development Value: E_ALL
 ; Production Value: E_ALL & ~E_DEPRECATED & ~E_STRICT
 ; http://php.net/error-reporting
-error_reporting = E_ALL & ~E_NOTICE
+error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT

 ; This directive controls whether or not and where PHP will output errors,
 ; notices and warnings too. Error output is very useful during development, but
@@ -594,7 +594,7 @@
 ; Example:
 ;error_log = php_errors.log
 ; Log errors to syslog (Event Log on Windows).
-error_log = syslog
+;error_log = syslog

 ; The syslog ident is a string which is prepended to every message logged
 ; to syslog. Only used when error_log is set to syslog.
@@ -929,7 +929,7 @@
 [Date]
 ; Defines the default timezone used by the date functions
 ; http://php.net/date.timezone
-date.timezone = Asia/Tokyo
+;date.timezone =

 ; http://php.net/date.default-latitude
 ;date.default_latitude = 31.7667
```

php-fpmサービスを稼働

```bash
sudo systemctl enable --now php-fpm
sudo systemctl status php-fpm
```
