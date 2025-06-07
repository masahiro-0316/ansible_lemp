nginx
=========

Nginx ウェブサーバをインストールし、リバースプロキシや静的コンテンツ配信の基本設定を行います。

要件
------------
- Ansible 2.9 以上  
- SELinux が有効な環境では事前に booleans を設定  

ロール変数
--------------
| 変数名                | 説明                                              | デフォルト値                                                             |
| --------------------- | ------------------------------------------------- | ------------------------------------------------------------------------ |
| `web_html_dir`        | ドキュメントルート（HTML 配信ディレクトリ）       | `/usr/share/nginx/html`                                                  |
| `nginx_conf_path`     | Nginx メイン設定ファイルパス                     | `/etc/nginx/nginx.conf`                                                  |
| `nginx_index_html`    | デフォルトの index.html ファイルパス             | `{{ web_html_dir }}/index.html`                                          |
| `vhostname`           | 仮想ホスト名                                       | `{{ ansible_hostname }}`                                                 |
| `tls_dir`             | TLS 関連ディレクトリのルート                     | `/etc/pki/nginx`                                                         |
| `tls_private_key_dir` | プライベートキー保存ディレクトリ                  | `{{ tls_dir }}/private`                                                  |
| `tls_certificate_dir` | 証明書保存ディレクトリ                            | `{{ tls_dir }}/certs`                                                    |
| `dhparam_file`        | Diffie-Hellman パラメータファイルパス             | `{{ tls_dir }}/dhparam.pem`                                              |

依存関係
------------
- `common`

サンプル Playbook
----------------
```yaml
- hosts: web
  roles:
    - role: nginx
      web_html_dir: "/var/www/html"
      vhostname: "example.com"
````

## ライセンス

This role is licensed under the Apache License, Version 2.0.
See [LICENSE](../../LICENSE) for details.
