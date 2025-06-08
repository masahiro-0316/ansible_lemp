nginx_php_fpm
=========

Nginx と PHP-FPM の連携設定を行い、PHP アプリケーションの実行環境を整備します。

要件
------------
- Ansible 2.9 以上  
- `nginx` および `php_fpm` ロールと併用すること  

ロール変数
--------------
| 変数名               | 説明                                     | デフォルト値                     |
| -------------------- | ---------------------------------------- | -------------------------------- |
| `php_ini_path`       | PHP 設定ファイルパス                     | `/etc/php.ini`                   |
| `php_fpm_conf_path`  | PHP-FPM プール設定ファイルパス           | `/etc/php-fpm.d/www.conf`        |

依存関係
------------
- `nginx`  
- `php_fpm`

サンプル Playbook
----------------
```yaml
- hosts: app
  roles:
    - role: nginx_php_fpm
      php_ini_path: "/etc/php/7.4/fpm/php.ini"
      php_fpm_conf_path: "/etc/php/7.4/fpm/pool.d/www.conf"
````

## ライセンス

This role is licensed under the Apache License, Version 2.0.
See [LICENSE](../../LICENSE) for details.
