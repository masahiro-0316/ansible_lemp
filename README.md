# LEMP環境自動構築用 Ansible Playbook

このリポジトリは、Linux サーバー上に Nginx・MariaDB・PHP-FPM からなる LEMP スタックを構築するための Ansible プレイブック集です。各種ロールや変数ファイルを利用して、環境の初期設定からミドルウェアの導入、自己署名証明書の発行まで自動化します。

## 構成

- **playbook**
  - `site.yml`  ― すべての処理を呼び出すメインプレイブック。
  - `1st_setup.yml` ― SSH 設定や共通設定など、基本サーバーの初期構築を実施。
  - `update_system.yml` ― OS のアップデートを行います。  
    - セキュリティアップデートのみ実行します。  
    - 何らかのアップデートが実行された場合は、OS再起動が実行されます。
    - 上記の２つが不要な場合は、`site.yml`から削除するかコメントアウトして下さい。
  - `4th_lemp.yml` ― LEMP 関連のロールを適用します。
    - LEMP環境の作動確認のため`adminer`の設定ロールが組み込まれています。
    - `adminer`への接続URL:`https://<サーバIP、ホスト名>/adminer**`
    - 本プレイブックを使用してLEMP環境だけ作成したい場合は、`adminer`ロールは削除してしまって問題ありません。
- **inventory**
  - `inventory/localhost.ini` ― ローカル環境向け設定。
  - `inventory/vagrant_development.ini` ― Vagrant 環境向け設定。
- **group_vars / host_vars**  ― 接続先ごとの変数定義。
- **roles**  ― nginx、mariadb、php_fpm など個別機能を実装したロール群。

### インストールソフトウェアのバージョン指定

`MariaDB`と`PHP`のバージョンは以下の変数で指定しています。

| ロール名            | 変数名             | 説明                      | デフォルト値 |
| --------------- | --------------- | ----------------------- | ------ |
| `roles/mariadb` | `mariadb_Ver`   | インストールする MariaDB のバージョン | `10.3` |
| `roles/php_fpm` | `php_version`   | インストールする PHP のバージョン     | `8.2`  |

## 検証実施済み環境

Ansible実行環境

- Python3.10

実行したAnsibleのバージョンは同階層にある`pip_ansible_requirements.txt`をご確認ください。

Vagrantイメージを使用して以下のOSへの実行検証済みとなります。

- Rocky8
- Rocky9

`Vagrant`ディレクトリ内に検証で使用したVgrantfileがありますが仮想化はKVMを使用しているのでVirtualBoxを使用している場合は、以下を参考に適宜ファイルの書き換えをして下さい。

> **VirtualBoxでVagrantを利用する場合の注意**
>
> デフォルトの `Vagrantfile` はKVM（libvirt）用の設定になっています。VirtualBoxで利用する場合は、以下の点を修正してください。
>
> 1. **providerの指定を変更**  
>    `config.vm.provider :libvirt do |p| ... end` を  
>    `config.vm.provider "virtualbox" do |vb| ... end` に変更します。
>
> 2. **libvirt専用の設定を削除**  
>    例: `management_network_address` や `dev`, `bridge` などlibvirt固有のオプションは削除またはVirtualBox用に調整します。
>
> 3. **CPU・メモリの指定方法を修正**  
>    VM定義内の `machine.vm.provider "libvirt" do |spec| ... end` を  
>    `machine.vm.provider "virtualbox" do |vb| ... end` に変更し、  
>    `vb.cpus = 4` や `vb.memory = 4096` のように指定します。
>
> 4. **ネットワーク設定の調整**  
>    `public_network` の `dev` や `bridge` オプションはVirtualBoxでは不要な場合が多いので、必要に応じて削除してください。
>
> 詳細な修正例が必要な場合は、`Vagrantfile`の該当箇所を参照してください。

## 事前準備

1. 必要な Python パッケージをインストールします。

   ```bash
   pip install -r pip_ansible_requirements.txt
   ```

2. 利用する Ansible コレクションを取得します。

   ```bash
   ansible-galaxy collection install -r ansible_galaxy.yml
   ```

3. Go言語制のサーバ設定テスト機能を設定する
   [goss公式GitHub](https://github.com/goss-org/goss)

   各ロールでインフラテストを実行しています。  
   テストにはGo言語で作成されたサーバ設定テスト機能を使用しています。

   ```bash
   sudo curl -L https://github.com/goss-org/goss/releases/latest/download/goss-linux-amd64 -o /usr/local/bin/goss
   sudo chmod +rx /usr/local/bin/goss
   ```

4. 実行後にデフォルト設定で以下のディレクトリが作成させる。

- config_backup
  - 各ロール実行後に設定ファイルの原本と編集後のファイルが格納される。  
    OS名のディレクトリが原本、ホス名のディレクトリが実行ホストで変更後の設定ファイルが格納される。
  - 自己署名署名書も格納される。
  - ディレクトリは、`.gitignore`でアップデート対象外になっている。

## 使い方

1. インベントリを選択します。ローカルで実行する場合は `inventory/localhost.ini`、開発用にVagrant で作成した仮想マシンへ実行する用に `inventory/vagrant_development.ini` が用意されている。
2. `site.yml` を実行してサーバーを構築します。

   ```bash
   ansible-playbook -i inventory/localhost.ini site.yml
   ```

   または

   ```bash
   ansible-playbook -i inventory/vagrant_development.ini site.yml
   ```

   > `update_system.yml`が有効になっている場合`-e sec=false`を追加することでOSのフルアップデートで最新化を実行します。

3. 必要に応じて `group_vars` や `host_vars` に定義されている各種変数を変更し、環境へ合わせた設定を行ってください。

## group_vars で設定されている主な変数

`group_vars` ディレクトリには、実行環境ごとの変数が YAML 形式で定義されています。目的に応じて値を変更することで、より柔軟にプレイブックを利用できます。

- `all/dir.yml`
  - バックアップ先や一時ファイル用ディレクトリのパスを定義します。例: `linux_backup_dir`、`local_backup_org` など
- `all/etc.yml`
  - SSH 接続ポート (`sshd_port`) や拡張認証用公開鍵パス (`ex_auth_keys`)、実行日時を保持する変数 (`run_date` など) を設定します。
  - MariaDB root パスワード(`mariadb_root_pass`)が記載してあります。
  - Ansibleのログインユーザ(`ansible_ssh_user`)
  - Ansibleのログインユーザパスワード(`ansible_become_pass:`)
- `lemp/nginx.yml`
  - Nginx 用 TLS 設定をまとめており、証明書の格納先ディレクトリや `server_subject_alt_name` といった項目を管理します。
- `vagrant/*.yml`
  - Vagrant 環境での接続ユーザーやパスワード

これらの変数を編集することで、デプロイ対象の環境や要件に合わせた設定を行うことが可能です。

## Docker コンテナでの実行

`docker-compose.yml` を利用すると、コンテナ内で Ansible を実行できます。
以下のようにコンテナを起動し、シェルに入って操作します。

```bash
docker compose run --rm ansible bash
```

### Docker利用時の留意点

- `.env`ファイルを使用してdockerコンテナ内のユーザとグループIDを設定している。
- ユーザIDとグループIDはデフォルトで1001で設定してある。
- 利用者は、適宜Dockerを実行するユーザのIDと同じになるように修正をして下さい。
- Docker環境は、実行ユーザの`~/.ssh`書き込み権限でマウントする設定をしている。

## ライセンス

Copyright 2025 古谷真大

 [Apache License Version 2.0](LICENSE.jp.md)（「本ライセンス」）に基づいてライセンスされます。  
 あなたがこのファイルを使用するためには、本ライセンスに従わなければなりません。  
 本ライセンスのコピーは下記の場所から入手できます。  

  [Apache License, Version 2.0オリジナルサイト：英語](http://www.apache.org/licenses/LICENSE-2.0)

適用される法律または書面での同意によって命じられない限り、本ライセンスに基づいて頒布されるソフトウェアは、明示黙示を問わず、いかなる保証も条件もなしに「現状のまま」頒布されます。本ライセンスでの権利と制限を規定した文言については、本ライセンスを参照してください。 
