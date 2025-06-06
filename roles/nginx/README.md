Role Name
=========

NginxのインストールとHTTPS接続設定にする

Requirements
------------

NginxをインストールしてHTTPポートを開放する
- nginx 1.14

Role Variables
--------------


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

Nginxのライセンスに準ずる

Author Information
------------------


マニュアルインストール
------


`Rocky 8`にNginxの手動でのインストール

[インストール参考サイト](https://www.server-world.info/query?os=CentOS_Stream_8&p=nginx&f=1)

1. nginxのインストール

Nginxをインストール

```bash
sudo dnf -y install nginx 
```

インストールの確認

```bash
nginx -v
```

1. 作動確認

サービスを自動起動に設定して起動を確認

```bash
sudo systemctl enable --now nginx
sudo systemctl status nginx
```

アクティブになっていることを確認

実際にデフォルトページが取得可能かを確認

```bash
curl http://localhost | grep -i nginx
```

`http`のファイヤーウォールの開放

```bash
sudo firewall-cmd --add-service=http
```

ブラウザから稼働サーバのIPへの接続を確認

ブラウザからの確認ができたらセキュリティのためデフォルトページを変更

```bash
mkdir -pv ~/backup.d/nginx
sudo mv -iv /usr/share/nginx/html/index.html ~/backup.d/nginx/
sudo vi /usr/share/nginx/html/index.html
```

```html
<html>
<body>
<div style="width: 100%; font-size: 40px; font-weight: bold; text-align: center;">
Hello world
I'm Test Page
</div>
</body>
</html>
```

`http`のファイヤーウォールの永続化

```bash
sudo firewall-cmd --runtime-to-permanent
```

再起動を実行してWebページが継続して確認可能であることを確認

```bash
sudo reboot
```

HTTPS設定
-------------------

nginxのHTTPS設定を行う。
TLSはすでに取得済みとする。

1. Nginx HTTPS設定

設定ファイルをバックアップ

```bash
mkdir -pv ~/backup.d/nginx_tls
sudo cp -iv /etc/nginx/nginx.conf ~/backup.d/nginx_tls/
```

HTTPS設定部分を編集

```bash
sudo vi /etc/nginx/nginx.conf
```
> TLS証明書のパスは作成しておいた証明書パスに合わせて異修正

編集後の差分を確認

```bash
sudo diff -usB  /etc/nginx/nginx.conf ~/backup.d/nginx_tls/nginx.conf
```

差分（変更部分のみ抜粋

```bash
--- /etc/nginx/nginx.conf       2024-03-20 17:04:19.239632977 +0900
+++ /home/daath/backup.d/nginx_tls/nginx.conf   2024-03-20 16:51:35.893277778 +0900
@@ -38,7 +38,6 @@
     server {
         listen       80 default_server;
         listen       [::]:80 default_server;
-        return       301 https://$host$request_uri;  # 全ての接続HTTPSへ転送
         server_name  _;
         root         /usr/share/nginx/html;

@@ -58,34 +57,34 @@
     }

 # Settings for a TLS enabled server.
-
-    server {
-        listen       443 ssl http2 default_server;
-        listen       [::]:443 ssl http2 default_server;
-        server_name  _;
-        root         /usr/share/nginx/html;
-
-        ssl_certificate "/etc/pki/tls/certs/server.crt";
-        ssl_certificate_key "/etc/pki/tls/private/server.key";
-        ssl_session_cache shared:SSL:1m;
-        ssl_session_timeout  10m;
-        ssl_ciphers PROFILE=SYSTEM;
-        ssl_prefer_server_ciphers on;
-
-        # Load configuration files for the default server block.
-        include /etc/nginx/default.d/*.conf;
-
-        location / {
-        }
-
-        error_page 404 /404.html;
-            location = /40x.html {
-        }
-
-        error_page 500 502 503 504 /50x.html;
-            location = /50x.html {
-        }
-    }
```

変更後の構文を確認

```bash
sudo nginx -t
```

以下のように出力されればOK

```bash
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

Nginxを再起動する。

```bash
sudo systemctl restart nginx
sudo systemctl status nginx
```

1. 設定の確認

ローカルからHTTP接続の場合は、リダイレクトされる事

```bash
curl -s http://localhost/
```

実行結果

```bash
<html>
<head><title>301 Moved Permanently</title></head>
<body bgcolor="white">
<center><h1>301 Moved Permanently</h1></center>
<hr><center>nginx/1.14.1</center>
</body>
</html>
```

ローカルからHTTPS接続を検証

```bsah
curl -s -k -v --tlsv1.2 https://localhost/
```

以下の値が確認できること

```bash
HTTP/2 200
```

ファイヤーウォールを開放

```bash
sudo firewall-cmd --add-service=https
```

ブラウザからアクセスして接続を検証
> http接続を明示指定してもHTTPSへ変更されることも確認する

`https`のファイヤーウォールの永続化

```bash
sudo firewall-cmd --runtime-to-permanent
```

再起動を実行してWebページが継続して確認可能であることを確認

```bash
sudo reboot
```
