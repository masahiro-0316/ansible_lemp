Role Name
=========

NginxからPHP-FPMを利用可能にする。

Requirements
------------

NginxからPHP-FPMを利用可能にする。

Role Variables
--------------

- php 8.0
- nginx 1.14

Dependencies
------------


Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: username.rolename, x: 42 }

License
-------

BSD

Author Information
------------------


マニュアル設定
--------

NginxのPHP-FPM手動設定手順を記述する


1. PHPの設定ファイルの変更


設定ファイルのバックアップ

```bash
mkdir -pv ~/backup.d/nginx_php_fpm
cp -iv /etc/php.ini ~/backup.d/nginx_php_fpm/
```

設定を編集

```bash
sudo sed \
-e 's/^;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' \
-i /etc/php.ini
```

> ```bash
> -e 's/^;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' \  # 公式ドキュメント指定の変更箇所
> ```

変更を確認

```bash
diff -ubB /etc/php.ini ~/backup.d/nginx_php_fpm/php.ini \
```

差分の確認

```bash
--- /etc/php.ini        2024-03-17 10:11:12.718249437 +0900
+++ /home/daath/backup.d/nginx_php_fpm/php.ini  2024-03-17 10:11:06.688147946 +0900
@@ -804,7 +804,7 @@
 ; of zero causes PHP to behave as before.  Default is 1.  You should fix your scripts
 ; to use SCRIPT_FILENAME rather than PATH_TRANSLATED.
 ; http://php.net/cgi.fix-pathinfo
-cgi.fix_pathinfo=0
+;cgi.fix_pathinfo=1

 ; if cgi.discard_path is enabled, the PHP CGI binary can safely be placed outside
 ; of the web tree and people will not be able to circumvent .htaccess security.
```

1. PHP-FPMの設定ファイルの変更


設定ファイルのバックアップ

```bash
cp -iv /etc/php-fpm.d/www.conf ~/backup.d/nginx_php_fpm/
```

設定を編集

```bash
sudo sed \
-e 's/^user = apache/user = nginx/g' \
-e 's/^group = apache/group = nginx/g' \
-e 's/;listen.owner = nobody/listen.owner = nginx/g' \
-e 's/;listen.group = nobody/listen.group = nginx/g' \
-e 's#;env\[PATH\].*#env\[PATH\] = /sbin:/bin:/usr/sbin:/usr/bin#g' \
-i /etc/php-fpm.d/www.conf
```

> 書き換えコマンドライン
> ```bash
> -e 's/^user = apache/user = nginx/g' \     #ApachからNginxへ変更
> -e 's/^group = apache/group = nginx/g' \     #ApachからNginxへ変更
> -e 's/;listen.owner = nobody/listen.owner = nginx/g' \  #Nginx仕様に変更
> -e 's/;listen.group = nobody/listen.group = nginx/g' \  #Nginx仕様に変更
> -e 's#;env\[PATH\].*#env\[PATH\] = /sbin:/bin:/usr/sbin:/usr/bin#g' \   #パスを追加
> ```

変更を確認

```bash
diff -ubB /etc/php-fpm.d/www.conf ~/backup.d/nginx_php_fpm/www.conf \
 | grep -e "^-" -e "^@@"
```

差分出力

```bash
--- /etc/php-fpm.d/www.conf     2024-03-17 10:01:25.686502781 +0900
@@ -21,9 +21,9 @@
-user = nginx
-group = nginx
@@ -45,14 +45,14 @@
-listen.owner = nginx
-listen.group = nginx
@@ -394,7 +394,7 @@
-env[PATH] = /sbin:/bin:/usr/sbin:/usr/bin
```

ログ出力ディレクトリのオーナーも変更
```bash
sudo chown -R nginx /var/log/php-fpm
sudo ls -la /var/log/php-fpm
```

変更後のPHP-FPM設定ファイルを確認
```bash
sudo php-fpm -t -y /etc/php-fpm.d/www.conf
```

以下の出力結果であればOK

```bash
[25-Mar-2024 10:58:38] NOTICE: configuration file /etc/php-fpm.d/www.conf test is successful
```

php-fpmサービスを再起動

```bash
sudo systemctl restart php-fpm
```

1. Nginx PHP-FPM連携の確認

PHPの情報を出力するPHPファイルを作成

```bash
echo "<?php phpinfo(); ?>" | sudo tee /usr/share/nginx/html/info.php
```

PHPの情報をローカルから確認する。

```bash
curl -k -s https://localhost/info.php | grep 'PHP Version' | tail -1 | sed -e 's/<[^>]*>//g'
```

以下のようにインストールしたバージョンの確認ができる

```bash
PHP Version 8.0.30
```

FPMの確認

```bash
curl -k -s https://localhost/info.php | grep -i "FPM" | sed -e 's/<[^>]*>//g'
```

```bash
Server API FPM/FastCGI
php-fpm active
fpm.configno valueno value
error_log/var/log/php-fpm/www-error.log/var/log/php-fpm/www-error.log
```

作動確認用のPHPバージョン情報出力ファイルをサンプルファイルに変更

```bash
echo '<html><div> <?php print("Hello World");?> </div></html>' | sudo tee /usr/share/nginx/html/info.php
```


