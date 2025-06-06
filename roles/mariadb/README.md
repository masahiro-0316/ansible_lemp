ロール名
=========

MariaDBのインストール

必要条件
------------

ロール変数
--------------

依存関係
------------

なし

使用例のPlaybook
----------------

ライセンス
-------

著者情報
------------------

MariaDBインストール手順
----------------------

RDMSのMariaDBインストール手順

[参考サイト：ServerWorld_CnetOSST8](https://www.server-world.info/query?os=CentOS_Stream_8&p=download)
[AnsibleでのMariaDB初期化](https://www.si1230.com/?p=38797)

- MariaDB 10.3
- Rocky 8

1. MariaDBをインストール

データベースをインストール

```bash
sudo dnf module install mariadb
```

インストールの確認

```bash
mysql --version
```


1. MariaDBの設定

データベースのサーバー設定ファイルを編集

```bash
mkdir -pv ~/backup.d/mariadb
cp -vi /etc/my.cnf.d/mariadb-server.cnf ~/backup.d/mariadb
sudo vi /etc/my.cnf.d/mariadb-server.cnf
```

変更差分を確認

```bash
diff -usb /etc/my.cnf.d/mariadb-server.cnf ~/backup.d/mariadb/mariadb-server.cnf
```
```bash
--- /etc/my.cnf.d/mariadb-server.cnf    2021-10-03 14:41:54.146296806 +0900
+++ /home/daath/backup.d/mariadb/mariadb-server.cnf     2021-10-03 14:33:48.577052798 +0900
@@ -18,10 +18,7 @@
 socket=/var/lib/mysql/mysql.sock
 log-error=/var/log/mariadb/mariadb.log
 pid-file=/run/mariadb/mariadb.pid
-expire_logs_days = 31
-character-set-server = utf8mb4
-slow_query_log=1
-slow_query_log_file=/var/log/mysql/slow_query.log
+

 #
 # * Galera-related settings
@@ -56,5 +53,3 @@
 # use this group for options that older servers don't understand
 [mariadb-10.3]

-[mysqld_safe]
-syslog
```

ログファイルの保存先を作成
```bash
sudo mkdir -pv -m 744 /var/log/mysql
```

アクセス権を設定
````bash
sudo chown mysql. /var/log/mysql/
```

設定を確認
```bash
ls -lZd /var/log/mysql
```
```bash
drwxr--r--. mysql mysql unconfined_u:object_r:var_log_t:s0 /var/log/mysql
```

データベースのクライアント設定ファイルを編集

```bash
cp -vi /etc/my.cnf.d/client.cnf ~/backup.d/mariadb
sudo vi /etc/my.cnf.d/client.cnf 
```

変更を確認

```bash
diff -usb /etc/my.cnf.d/client.cnf ~/backup.d/mariadb/client.cnf
```

```bash
--- /etc/my.cnf.d/client.cnf    2024-04-23 20:27:41.691237015 +0900
+++ /home/daath/backup.d/mariadb/client.cnf     2024-04-23 20:26:48.462347487 +0900
@@ -5,7 +5,6 @@


 [client]
-default-character-set = utf8mb4

 # This group is not read by mysql client library,
 # If you use the same .cnf file for MySQL and MariaDB,
```

MariaDBを常駐起動させます。
```bash
sudo systemctl enable --now mariadb 
sudo systemctl status mariadb 
```

ログの取得を確認

```bash
sudo ls -l /var/log/mysql/
```


1. データベースの初期設定

データベースの初期化を行う

1. Rootパスワードの設定
1. 匿名ユーザーの削除
1. Rootのリモートログイン無効
1. テストデータベースの削除

```bash
mysql_secure_installation 
```

対話式で初期化が始まります。

```bash
NOTE: RUNNING ALL PARTS OF THIS SCRIPT IS RECOMMENDED FOR ALL MariaDB
      SERVERS IN PRODUCTION USE!  PLEASE READ EACH STEP CAREFULLY!

In order to log into MariaDB to secure it, we'll need the current
password for the root user.  If you've just installed MariaDB, and
you haven't set the root password yet, the password will be blank,
so you should just press enter here.

Enter current password for root (enter for none): #既存のパスワード要求となる。初期化するので空でエンター
OK, successfully used password, moving on...

Setting the root password ensures that nobody can log into the MariaDB
root user without the proper authorisation.

Set root password? [Y/n] y #Rootパスワードを設定するので[Y]
New password: # rootパスワード入力
Re-enter new password:
Password updated successfully!
Reloading privilege tables..
 ... Success!


By default, a MariaDB installation has an anonymous user, allowing anyone
to log into MariaDB without having to have a user account created for
them.  This is intended only for testing, and to make the installation
go a bit smoother.  You should remove them before moving into a
production environment.

Remove anonymous users? [Y/n] y # 匿名ユーザーは削除するので[Y]
 ... Success!

Normally, root should only be allowed to connect from 'localhost'.  This
ensures that someone cannot guess at the root password from the network.

Disallow root login remotely? [Y/n] y #遠隔からRootログインを禁止するので[Y]
 ... Success!

By default, MariaDB comes with a database named 'test' that anyone can
access.  This is also intended only for testing, and should be removed
before moving into a production environment.

Remove test database and access to it? [Y/n] y #最初からある試験ようデータベースを削除するので[Y]
 - Dropping test database...
 ... Success!
 - Removing privileges on test database...
 ... Success!

Reloading the privilege tables will ensure that all changes made so far
will take effect immediately.

Reload privilege tables now? [Y/n] y #特権テーブルを再読み込みするので[Y]
 ... Success!

Cleaning up...

All done!  If you've completed all of the above steps, your MariaDB
installation should now be secure.

Thanks for using MariaDB!
```

以上で初期化が完了

Rootでログインして設定を確認する。

```bash
mysql -uroot -p
```
> パスワード要求させるので初期化時に入力したRootパスワードを入力
> ログインしないで取得する場合は、-e オプションのあとにSQL構文を「””」

データベースにログイン出来たらまずは、バイナリィログ保持期間の確認
```mysql
SHOW GLOBAL VARIABLES like 'expire_logs_days';
```
```mysql
+------------------+-------+
| Variable_name    | Value |
+------------------+-------+
| expire_logs_days | 31    |
+------------------+-------+
```

DB設定ファイルで設定した文字コードの確認

```mysql
show variables like 'char%';
```
```mysql
+--------------------------+------------------------------+
| Variable_name            | Value                        |
+--------------------------+------------------------------+
| character_set_client     | utf8mb4                      |
| character_set_connection | utf8mb4                      |
| character_set_database   | utf8mb4                      |
| character_set_filesystem | binary                       |
| character_set_results    | utf8mb4                      |
| character_set_server     | utf8mb4                      |
| character_set_system     | utf8                         |
| character_sets_dir       | /usr/share/mariadb/charsets/ |
+--------------------------+------------------------------+
```

ユーザー情報の確認
```mysql
select user,host,password from mysql.user;
```
```mysql
+------+-----------+-------------------------------------------+
| user | host      | password                                  |
+------+-----------+-------------------------------------------+
| root | localhost | *E8DAC3C4765599C8BD2DC15E0A609D70E21007FA |
| root | 127.0.0.1 | *E8DAC3C4765599C8BD2DC15E0A609D70E21007FA |
| root | ::1       | *E8DAC3C4765599C8BD2DC15E0A609D70E21007FA |
+------+-----------+-------------------------------------------+
```

DBの確認
```mysql
show databases;
```
```mysql
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
+--------------------+
```

データベースから抜ける

```bash
exit
```

1. その他事後作業

mysqlログローテーション設定変更

```bash
cp -iv  /etc/logrotate.d/mariadb ~/backup.d/mariadb/
sudo vi /etc/logrotate.d/mariadb
```

```bash
/var/log/mysql/*log {
    daily
    missingok
    notifempty
    dateext
    rotate 60
    sharedscripts
    postrotate
    if test -x /usr/bin/mysqladmin && \
        /usr/bin/mysqladmin --defaults-extra-file=/root/.my.cnf ping &>/dev/null
    then
        /usr/bin/mysqladmin --defaults-extra-file=/root/.my.cnf flush-logs
    fi
    endscript
}
```

差分を確認

```bash
diff -usb /etc/logrotate.d/mariadb ~/backup.d/mariadb/mariadb
```

```bash
--- /etc/logrotate.d/mariadb    2024-04-23 20:36:27.852070970 +0900
+++ /home/daath/backup.d/mariadb/mariadb        2024-04-23 20:36:17.054890097 +0900
@@ -5,7 +5,7 @@
 # [mysqld]
 # log-error=/var/log/mariadb/mariadb.log

-/var/log/mariadb/*.log {
+/var/log/mariadb/mariadb.log {
         create 600 mysql mysql
         su mysql mysql
         notifempty
```

ログローテーション試験

```bash
sudo logrotate -dv /etc/logrotate.d/mariadb
```
```bash
reading config file /etc/logrotate.d/mysql
Allocating hash table for state file, size 15360 B

Handling 2 logs

rotating pattern: /var/log/nginx/*log /var/log/php/*log  after 1 days (60 rotations)
empty log files are not rotated, old logs are removed
#####[中略]#####
rotating pattern: /var/log/mysql/*log  after 1 days (60 rotations)
empty log files are not rotated, old logs are removed
```

以上作業完了
