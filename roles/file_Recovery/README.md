file_Recovery
=========

各種設定ファイルやログなどを収集し、指定の回収ディレクトリへ格納します。

要件
------------
- Ansible 2.9 以上  

ロール変数
--------------
本ロールでは defaults/main.yml に設定された変数はありません。

依存関係
------------
- `common`：作業ディレクトリや変数設定を共通化

サンプル Playbook
----------------
```yaml
- hosts: all
  roles:
    - role: file_Recovery
````

## ライセンス

This role is licensed under the Apache License, Version 2.0.
See [LICENSE](../../LICENSE) for details.
