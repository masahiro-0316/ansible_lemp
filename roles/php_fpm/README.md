php_fpm
=========

PHP-FPM をインストールし、基本設定を行います。

要件
------------
- Ansible 2.9 以上  

ロール変数
--------------
| 変数名          | 説明                             | デフォルト値   |
| --------------- | -------------------------------- | -------------- |
| `php_version`   | インストールする PHP のバージョン | `8.2`          |
| `php_ini_path`  | PHP 設定ファイルパス             | `/etc/php.ini` |

依存関係
------------
- `common`

サンプル Playbook
----------------
```yaml
- hosts: app
  roles:
    - role: php_fpm
      php_version: "8.1"
````

## ライセンス

This role is licensed under the Apache License, Version 2.0.
See [LICENSE](../../LICENSE) for details.
