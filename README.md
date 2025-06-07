# LEMP環境自動構築用 Ansible Playbook

このリポジトリは、Linux サーバー上に Nginx・MariaDB・PHP-FPM からなる LEMP スタックを構築するための Ansible プレイブック集です。各種ロールや変数ファイルを利用して、環境の初期設定からミドルウェアの導入、自己署名証明書の発行まで自動化します。

## 構成

- **playbook**
  - `site.yml`  ― すべての処理を呼び出すメインプレイブック。
  - `1st_setup.yml` ― SSH 設定や共通設定など、基本サーバーの初期構築を実施。
  - `update_system.yml` ― OS のアップデートを行います。
  - `4th_lemp.yml` ― LEMP 関連のロールを適用します。
- **inventory**
  - `inventory/localhost.ini` ― ローカル環境向け設定。
  - `inventory/vagrant_development.ini` ― Vagrant 環境向け設定。
- **group_vars / host_vars**  ― 接続先ごとの変数定義。
- **roles**  ― nginx、mariadb、php_fpm など個別機能を実装したロール群。

## 事前準備

1. 必要な Python パッケージをインストールします。
   ```bash
   pip install -r pip_ansible_requirements.txt
   ```
2. 利用する Ansible コレクションを取得します。
   ```bash
   ansible-galaxy collection install -r ansible_galaxy.yml
   ```

## 使い方

1. インベントリを選択します。ローカルで実行する場合は `inventory/localhost.ini`、Vagrant で作成した仮想マシンへ実行する場合は `inventory/vagrant_development.ini` を指定します。
2. `site.yml` を実行してサーバーを構築します。
   ```bash
   ansible-playbook -i inventory/localhost.ini site.yml
   ```
   または
   ```bash
   ansible-playbook -i inventory/vagrant_development.ini site.yml
   ```
3. 必要に応じて `group_vars` や `host_vars` に定義されている各種変数を変更し、環境へ合わせた設定を行ってください。

## Docker コンテナでの実行

`docker-compose.yml` を利用すると、コンテナ内で Ansible を実行できます。
以下のようにコンテナを起動し、シェルに入って操作します。
```bash
docker compose run --rm ansible bash
```

## ライセンス

このプロジェクトは [Apache License 2.0](LICENSE) の下で公開されています。
