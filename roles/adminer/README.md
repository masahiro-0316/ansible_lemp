adminer
=========

Adminer ウェブベース管理ツールをセットアップし、PostgreSQL データベースに対する接続環境を整備します。

要件
------------
- Ansible 2.9 以上  
- ターゲットホストに PostgreSQL がインストール済み  
- PHP 実行環境（php-cli など）が利用可能  

ロール変数
--------------
| 変数名               | 説明                                                     | デフォルト値                                                                             |
| -------------------- | -------------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| `adminer_github_url` | Adminer PHP ファイルのダウンロード元 GitHub リリース URL | `https://github.com/vrana/adminer/releases/download/v5.3.0/adminer-5.3.0.php`              |

依存関係
------------
- `common`：OS ファミリー依存の変数設定  
- （必要に応じて）`php_fpm`／`nginx_php_fpm` などで PHP 環境を整備

サンプル Playbook
----------------
```yaml
- hosts: db
  roles:
    - role: adminer
      # インストールするAdminerを変更したい場合は以下の用にGitHubのURLを指定する。
      adminer_github_url: "https://github.com/vrana/adminer/releases/download/v5.3.0/adminer-5.3.0.php" 
````

## ライセンス

This role is licensed under the Apache License, Version 2.0.
See [LICENSE](../../LICENSE) for details.
