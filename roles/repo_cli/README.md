# 参考URLを貼る

[CentOS8 Remi repo GPG鍵](https://github.com/ansible/ansible/issues/71634)
ロールの役割
=========
CentOS7 KVM初期設定と環境事にベースIPへの切り替えを行う

前提環境
------------
キックスタータ（KS）でSSHの初期設定とSSHの公開鍵の転送が完了している事
所定のIPアドレスの200なっている事。

変数の設定
--------------
KSインストール時の初期IPアドレスと各ベース環境のIPアドレスとホスト名、DNSIPとドメイン名
ベース環境の共通の管理者パスワード、DBのパスワード

手動手順書
----------------
CentOS7の共通初期設定を行います。
Rootパスワードをロックする。

#カーネルバージョン保持を5から２へ変更してシステム最新化
sudo sed -e '/^installonly_limit/s/5/2/g' -i.org /etc/yum.conf

#TCP wappwe
sed -i '$asshd: 127.0.0.1 192.168.33.' /etc/hosts.allow
sed -i '$aALL: ALL' /etc/hosts.deny

#システムの最新化
sudo yum clean all
sudo yum update

#標準リポジトリを優先する設定にする
yum -y install yum-plugin-priorities
sed -i.org -e "s/\]$/\]\npriority=1/g" /etc/yum.repos.d/CentOS-Base.repo

#PHP関係は、排他的にインストール
sed -i -e "s/\[base\]$/\[base\]\nexclude=php\*/g" /etc/yum.repos.d/CentOS-Base.repo
sed -i -e "s/\[updates\]$/\[updates\]\nexclude=php\*/g" /etc/yum.repos.d/CentOS-Base.repo
sed -i -e "s/\[extras\]$/\[extras\]\nexclude=php\*/g" /etc/yum.repos.d/CentOS-Base.repo

#Fedoraプロジェクトが提供するRHEL用ビルドパッケージEPEL
yum -y install epel-release
sed -i.org -e "s/enabled=1/enabled=0/g" /etc/yum.repos.d/epel.repo

#CentOS SCLo Software collections を追加します。
sudo yum -y install centos-release-scl-rh centos-release-scl
sudo sed -i.org -e "s/enabled=1/enabled=0/g" /etc/yum.repos.d/CentOS-SCLo-scl.repo
sudo sed -i.org -e "s/enabled=1/enabled=0/g" /etc/yum.repos.d/CentOS-SCLo-scl-rh.repo

#便利なパッケージが数多く配布されている Remi's RPM repository を追加します。
sudo yum -y install http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
sudo sed -i.org -e "s/enabled=1/enabled=0/g" /etc/yum.repos.d/remi-safe.repo

#セキュリティのみの自動アップデート
sudo yum -y install yum-cron
sudo sed -i.org -e "s/update_cmd = default/update_cmd = security/" /etc/yum/yum-cron.conf
 
#NTPサーバ（chrony）の設定
sudo sed \
-e 's/server 0.centos.pool.ntp.org iburst/server ntp.nict.jp iburst/' \
-e 's/server 1.centos.pool.ntp.org iburst/server ntp1.jst.mfeed.ad.jp iburst/' \
-e 's/server 2.centos.pool.ntp.org iburst/server ntp2.jst.mfeed.ad.jp iburst/' \
-e 's/server 3.centos.pool.ntp.org iburst/server ntp3.jst.mfeed.ad.jp iburst/' \
-i.org /etc/chrony.conf

#SElinux SETroubleShoot設定
sudo yum -y install setroubleshoot-server
echo 'D /var/run/setroubleshoot 0755 setroubleshoot root - ' |tee /etc/tmpfiles.d/setroubleshoot.conf
chown setroubleshoot:root /var/run/setroubleshoot
chmod 755 /var/run/setroubleshoot

#接続許可をするIPの範囲を限定
sudo firewall-cmd --add-source=192.168.33.0/24 --permanent
sudo firewall-cmd --add-source=10.8.0.0/24 --permanent

#ファイヤーウォールを再起動
sudo firewall-cmd --reload
sudo firewall-cmd --list-all

#以上共通設定を終わりになります。
