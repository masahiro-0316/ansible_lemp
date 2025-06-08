mariadb
=========

MariaDB データベースサーバをインストールし、初期設定を行います。

要件
------------
- Ansible 2.9 以上  
- ターゲットホストに root 権限または sudo 権限が必要  

ロール変数
--------------
| 変数名        | 説明                                 | デフォルト値      |
| ------------- | ------------------------------------ | ----------------- |
| `new_db_dir`  | MariaDB のデータディレクトリパス     | `/var/lib/mysql`  |
| `mariadb_Ver` | インストールする MariaDB のバージョン | `10.3`            |

依存関係
------------
- `common`  

サンプル Playbook
----------------
```yaml
- hosts: db
  roles:
    - role: mariadb
      new_db_dir: "/data/mysql"
      mariadb_Ver: "10.5"
````

## ライセンス

This role is licensed under the Apache License, Version 2.0.
See [LICENSE](../../LICENSE) for details.
