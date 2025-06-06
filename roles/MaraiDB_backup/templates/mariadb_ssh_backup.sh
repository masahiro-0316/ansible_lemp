#!/bin/bash -xe
#### 所要時間計測
SECONDS=0

### 変数定義 ログ出力＆接続情報
. ${HOME}/.work.d/`basename $0 .sh`.conf
. /root/.work.d/.secret.conf

### ホストサーバ バックアップリストア
TARGET_NAME={{ terget_name }}
TARGET_SERVER={{ terget_server }}
REMOT_BACKUP_DIR={{ db2fs_backup_dir }}
LOCAL_BACKUP_DIR=/opt/db/mariabackup
SSH_CONF={{ ssh_config }} 
#BACKUP_DIR=/home/smith/test

# 自身が起動していたら終了
if [ $$ != `pgrep -fo $0`  ]; then
    echo "[`date '+%Y/%m/%d %T'`] myself is already running. exit myself."  | tee -a ${SKIP_LOGS}
    tail -50 ${SCRIPT_LOG}  | mail -s "[`hostname -s `]:`basename $0` Myself is Already running. EXIT myself" ${MAIL_ADDRESS}
    exit 1
fi

### スクリプト開始メール
{
echo "`date`: `basename $0`"
echo "データベースのバックアップを開始します"
} | mail -s "[`hostname -s `]:`basename $0` Scrpt Work START" ${MAIL_ADDRESS}

# メール送信のため待機
sleep 1

### メイン書理
{
ping -c 1 ${TARGET_SERVER}
if [ $? -eq 0 ]; then
	echo "" 
	echo "[`date '+%Y/%m/%d %T'`] ####################作業開始####################"
	echo "[`date '+%Y/%m/%d %T'`] ${HOSTNAME}サーバのデータベースバックアップの開始" 
        ### MariaDB バックアップ 
        BACKUP_NAME=`hostname -s`-mariadb_${DATE}
        ### 前回のディレクトリを削除
        cd ${LOCAL_BACKUP_DIR} && pwd
	if [ $? == 0 ] && [ `cd ${LOCAL_BACKUP_DIR} && ls | wc -l` != 0 ]; then
		echo "[`date '+%Y/%m/%d %T'`] 前回のディレクトリを削除"
        	cd ${LOCAL_BACKUP_DIR} && ls -1
        	cd ${LOCAL_BACKUP_DIR} && rm -rf ${LOCAL_BACKUP_DIR}
	fi
        cd
        ### 今回のローカルディレクトリを作成
	echo "[`date '+%Y/%m/%d %T'`] "
	echo "[`date '+%Y/%m/%d %T'`] 今回のローカルディレクトリを作成"
        mkdir -pv -m 750 ${LOCAL_BACKUP_DIR}/${BACKUP_NAME}
        mkdir -pv -m 750 ${LOCAL_BACKUP_DIR}/`hostname -s`
        ### リモートディレクトリを作成
        ssh -F ${SSH_CONF} ${TARGET_NAME} "mkdir -pv ${REMOT_BACKUP_DIR}"
        #### バックアップを実行
	echo "[`date '+%Y/%m/%d %T'`] "
	echo "[`date '+%Y/%m/%d %T'`] バックアップを実行"
        # mariabackup --backup --target-dir <保存先ディレクトリ> --user=root
        mariabackup --backup --rsync -S {{ new_mariadb_socket }} --target-dir ${LOCAL_BACKUP_DIR}/`hostname -s` --user=root 2> ${DUMP_LOG} 
        EXIT=$?
        RC=$((RC+EXIT))
        echo "[`date '+%Y/%m/%d %T'`] Mariabackup終了ステータス ${RC}"
        if [ ${EXIT} -eq 0 ]; then
                echo "[`date '+%Y/%m/%d %T'`] "
                echo "[`date '+%Y/%m/%d %T'`] バックアップデータをアーカイブ"
                tar -cvf ${LOCAL_BACKUP_DIR}/${BACKUP_NAME}/mariadb.tar ${LOCAL_BACKUP_DIR}/`hostname -s`
                EXIT=$?
                RC=$((RC+EXIT))
                echo "[`date '+%Y/%m/%d %T'`] "
                echo "[`date '+%Y/%m/%d %T'`] mariadb-${DATE}.tarのハッシュ値を取得"
                cd ${LOCAL_BACKUP_DIR};sha512sum ${BACKUP_NAME}/mariadb.tar | \
                tee ${LOCAL_BACKUP_DIR}/${BACKUP_NAME}/sha512sum_mariadb-${DATE}.txt  
		### パスワードZIPにしながらリモートへ転送
	        # zip -P <<ZIPパスワード>> -mr - «圧縮対象ディレクトリ» | ssh «リモートホスト» "cat > «リモートでの書き出し先圧縮ファイルパス»"	
                cd ${LOCAL_BACKUP_DIR};zip -P ${PASSWD} -mr - ${BACKUP_NAME} | \
                ssh -F ${SSH_CONF} ${TARGET_NAME} "cat > ${REMOT_BACKUP_DIR}/${BACKUP_NAME}.zip" 
		RC=$?
		echo "[`date '+%Y/%m/%d %T'`] 終了ステータス　${RC}" 
		if [ ${RC} -eq 0 ]; then
			echo "[`date '+%Y/%m/%d %T'`] ${REMOT_BACKUP_DIR}/${BACKUP_NAME}.zip にバックアップ完了" 
		else
			echo "[`date '+%Y/%m/%d %T'`] バックアップが失敗しました。" 
			echo "[`date '+%Y/%m/%d %T'`] debug_`basename $0 .sh`_$(date +%d).logを確認してください" 
		fi
        fi
	echo "[`date '+%Y/%m/%d %T'`] データベースバックアップの終了" 
	echo "[`date '+%Y/%m/%d %T'`] ###########################################" 
	echo "" 
fi
TIME=$SECONDS
echo "[`date '+%Y/%m/%d %T'`] ${TIME}秒で処理を終了"
JIKAN=$((${TIME}/3600))
FUN=$((((${TIME}%3600))/60))
BYO=$(((${TIME}%3600)%60))
echo "[`date '+%Y/%m/%d %T'`] 所要時間 ${JIKAN}時間 ${FUN}分 ${BYO}秒"
echo "[`date '+%Y/%m/%d %T'`] ###################作業終了########################"
echo "[`date '+%Y/%m/%d %T'`]"
} | tee -a ${SCRIPT_LOG}
# 全ての処理が完了するのを待ちます
wait
# debug code
#echo "[`date '+%Y/%m/%d %T'`] $1 1st" | tee -a ${TEST_LOG}
#sleep 10
#exit 0

### スクリプト終了メール
sleep 3
cat ${SCRIPT_LOG} | mail -s "[`hostname -s `]:`basename $0` Scrpt Work END" ${MAIL_ADDRESS}


