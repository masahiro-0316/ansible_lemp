common
=========

全ロール共通の環境設定およびファイル回収機構を提供します。

要件
------------
- Ansible 2.9 以上  

ロール変数
--------------
本ロールでは defaults/main.yml に設定された変数はありません。

依存関係
------------
なし

サンプル Playbook
----------------

```yaml
- hosts: all
  roles:
    - role: common
````

## ライセンス

This role is licensed under the Apache License, Version 2.0.
See [LICENSE](../../LICENSE) for details.
