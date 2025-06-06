MariaDBリモートバックアップ設定
===============================

MariaDBのデータベースをバックアップしてリモートサーバに保存する手順について記載

[MariDB公式ドキュメント](https://mariadb.com/ja/resources/blog/backup-restore-with-mariabackup/)

バックアップ方法専用の**Mariabackup**コマンドを使用して行う
このコマンドでバックアップしたデータは、**10.2**から**10.3**へリストアなどバージョンを超えてリストアする事も可能なよう

パッケージインストール
---------------------

コマンドのパッケージをインストールする。

RedHat系統

```bash
sudo yum install MariaDB-backup
```

Debian系統

```bash
sudo apt-get install mariadb-backup
```

バックアップを実行
------------------

バックアップを実行する
```bash
mariabackup --backup \
   --target-dir=/var/mariadb/backup/ \
   --user=mariabackup --password=mypassword
```
> このコマンドで**/var/mariadb/backup**ディレクトリ内にバックアップデータが保存される。

**mariabackup**コマンドは、オプションファイルもサポートしているため、ユーザーとパスワードをコマンドで指定したくない場合はオプションファイルに以下の設定を入れる事でユーザー名とパスワードのコマンドオプションを回避できる

```mysql
[mariabackup]
user=mariabackup
password=mypassword
```
> [mariabackup]は[client]でも可のよう

オプションファイルはコマンド実行ユーザーのホームディレクトリに**~/.my.cof**などに作成する。

MariaDB リストア
---------------

専用コマンド**mariabackup**を使ったリストア手順について記述する
リストア時にはデータベースディレクトリが空でないとエラーとなる
> ローカルインストールのZabbixをリストアする

リストア作業はRootユーザーで実施する
```bash
sudo -i
```

バックアップデータを解凍
```bash
cd /srv/backups/zabbix 
unzip kether-mariadb_202204262230.zip 
```

チェックサムを確認
```bash
sha512sum --check <バックアップデータディレクトリ>/<チェックサムファイル>
```

tarボールを転換
```bash
time tar xvf kether-mariadb_202204262230/mariadb.tar -C /srv/backups/zabbix
```

リストアデータの一貫性を試験

```bash
mariabackup --prepare --target-dir /srv/backups/zabbix/<バックアップ解凍ディレクトリ>
```

実行結果
```bash
[00] 2022-04-27 21:31:39 Last binlog file , position 0
[00] 2022-04-27 21:31:39 completed OK!
```
> **completed OK!**が出力されればOK


データベースを停止
```bash
systemctl stop mariadb
systemctl status mariadb
```

データベースディレクトリをからにしておく
```bash
ls -d /var/lib/mysql/ \
&& rm -fr $_/* \
&& ls -la $_/

```
> 上記はデフォルトのデータベースディレクトリとなる。別途サーバー設定ファイルの**datadir**オプションなのでデータベースディレクトリを変更していた場合は、該当のディレクトリをからにしておく事

リストア実行
```bash
time mariabackup --copy-back --target-dir /srv/backups/zabbix/<バックアップ解凍ディレクトリ>
```
> このコマンドでは、**/tmp/backup**ディレクトリ内に設置したバックアップデータがリストアされる
> ```bash
> mariabackup --copy-back --target-dir /tmp/backup
> ```

実行結果
```bash
[01] 2022-04-27 21:41:01         ...done
[00] 2022-04-27 21:41:01 completed OK!

real    0m54.388s
user    0m0.025s
sys     0m4.028s
```
> **completed OK!**が出力されればOK

パーミッションを修正
```bash
cd /var/lib/mysql/ \
&& chown -R mysql:mysql . \ 
&& restorecon -Rv . \
&& ls -laZ 
```

データベースを再起動
```bash
systemctl start mariadb
systemctl status mariadb
```

その他
------

オプションなどの確認方法

```bash
mariabackup --help
```

バックアップの高速化

バックアップコマンドに**--rsync**オプションを付与するとバックアップ速度が早くなる

オプションなし

```bash
real    0m2.419s
user    0m0.086s
sys     0m0.229s
```

オプションあり

```bash
real    0m2.395s
user    0m0.086s
sys     0m0.228s
```

データ数が少ないため微々たるものだがmariabackupのヘルプではデータ量が多くなるほど顕著になるとのこと
```txt 原文
Uses the rsync utility to optimize local file transfers. When this option is specified, innobackupex uses rsync to copy all non-InnoDB files instead of spawning a separate cp for each file, which can be much faster for servers with a large number of databases or tables.  This option cannot be used together with --stream.
```
```txt google翻訳
rsyncユーティリティを使用して、ローカルファイル転送を最適化します。 このオプションを指定すると、innobackupexはrsyncを使用して、ファイルごとに個別のcpを生成する代わりに、すべての非InnoDBファイルをコピーします。これにより、データベースまたはテーブルが多数あるサーバーの場合、はるかに高速になります。 このオプションは、-streamと一緒に使用することはできません。 
```

MariaDB Upgeade
---------------

資料は、10.3から10.5へアップグレードする手順となる

[参考：RedHat公式ドキュメント](https://access.redhat.com/documentation/ja-jp/red_hat_enterprise_linux/8/html/deploying_different_types_of_servers/upgrading_from_a_rhel_8_version_of_mariadb_10_3_to_mariadb_10_5)

作業はRootユーザーで実行する

```bash
sudo -i
```

MariaDB サーバーを停止します。

```bash
systemctl stop mariadb.service
systemctl status mariadb.service
````

以下のコマンドを実行して、後続のストリームに切り替えるためのシステムの準備が整っているかどうかを判断します。

```bash
yum distro-sync
```
> このコマンドは、Nothing to do.Complete! のメッセージで終了する必要があります。詳細は、「後続のストリームへの切り替え」を参照してください。

システムで mariadb モジュールをリセットします。
```bash
yum module reset mariadb
```

新しい mariadb:10.5 モジュールストリームを有効にします。

```bash
yum module enable mariadb:10.5
```

インストール済みパッケージを同期し、ストリーム間の変更を実行します。

```bash
yum distro-sync
```

これにより、インストールされている MariaDB パッケージがすべて更新されます。
/etc/my.cnf.d/ にあるオプションファイルに MariaDB 10.5 に対して有効なオプションのみが含まれるように、設定を調整します。
詳細は、MariaDB 10.4 および MariaDB 10.5 のアップストリームドキュメントを参照してください。

MariaDB サーバーを起動します。
スタンドアロンを実行しているデータベースをアップグレードする場合:

```bash
systemctl start mariadb.service
systemctl status mariadb.service
```

### Galera クラスターノードをアップグレードする場合:

```bash
galera_new_cluster
```

mariadb サービスが自動的に起動します。 

### mariadb-upgrade ユーティリティーを実行して、内部テーブルをチェックし、修復します。

スタンドアロンを実行しているデータベースをアップグレードする場合:
```bash
mariadb-upgrade
```

実行結果
```bash
Phase 7/7: Running 'FLUSH PRIVILEGES'
OK
```


Galera クラスターノードをアップグレードする場合:
```bash
mariadb-upgrade --skip-write-binlog
```

全て完了したらアップグレード前まで稼働していたMariaDBを使用していたアプル類の作動がおかしくないか確認しておく



