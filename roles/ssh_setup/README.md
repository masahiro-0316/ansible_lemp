ssh_setup
=========

SSH デーモンおよびクライアントの設定を行い、セキュアな接続環境を構築します。

要件
------------
- Ansible 2.9 以上  
- ターゲットホストに SSHd がインストール済み  

ロール変数
--------------
| 変数名      | 説明                              | デフォルト値 |
| ----------- | --------------------------------- | ------------ |
| `sshd_port` | SSH デーモンがリッスンするポート番号 | `22`         |

依存関係
------------
- `common`

サンプル Playbook
----------------
```yaml
- hosts: all
  roles:
    - role: ssh_setup
      sshd_port: 2222
````

## ライセンス

This role is licensed under the Apache License, Version 2.0.
See [LICENSE](../../LICENSE) for details.