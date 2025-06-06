#!/bin/bash -xe
#### 所要時間計測
SECONDS=0

### 変数定義 ログ出力＆接続情報
. ${HOME}/.work.d/`basename $0 .sh`.conf
. /root/.work.d/.secret.conf

### ホストサーバ バックアップリストア
LOCAL_BACKUP_DIR={{ db2fs_backup_dir }}

# 自身が起動していたら終了
# ラッピングスクリプトで実行する場合は、コメントアウトする
#if [ $$ != `pgrep -fo $0`  ]; then
#    echo "[`date '+%Y/%m/%d %T'`] myself is already running. exit myself."  | tee -a ${SKIP_LOGS}
#    tail -50 ${SCRIPT_LOG}  | mail -s "[`hostname -s `]:`basename $0` Myself is Already running. EXIT myself" ${MAIL_ADDRESS}
#    exit 1
#fi

### スクリプト開始メール
{
echo "`date`: `basename $0`"
echo "データベースのバックアップを開始します"
} | mail -s "[`hostname -s `]:`basename $0` Scrpt Work START" ${MAIL_ADDRESS}

# メール送信のため待機
sleep 1

### メイン書理
{
ls -d {{ db2fs_backup_dir }}
if [ `mount | grep "{{ db2fs_backup_dir }}" | wc -l` -ge 1 ]; then
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
        	cd ${LOCAL_BACKUP_DIR} && rm -rfv ${LOCAL_BACKUP_DIR}/*
	fi
        cd
        ### 今回のローカルディレクトリを作成
	echo "[`date '+%Y/%m/%d %T'`] "
	echo "[`date '+%Y/%m/%d %T'`] 今回のローカルディレクトリを作成"
        mkdir -pv -m 750 ${LOCAL_BACKUP_DIR}/${BACKUP_NAME}
        mkdir -pv -m 750 ${LOCAL_BACKUP_DIR}/`hostname -s`
        #### バックアップを実行
	echo "[`date '+%Y/%m/%d %T'`] "
	echo "[`date '+%Y/%m/%d %T'`] Zabbixサーバ停止"
        systemctl stop zabbix-server.service
	echo "[`date '+%Y/%m/%d %T'`] "
	echo "[`date '+%Y/%m/%d %T'`] バックアップを実行"
        # mariabackup --backup --target-dir <保存先ディレクトリ> --user=root
        #mariabackup --backup --rsync -S {{ mariadb_socket }} --target-dir ${LOCAL_BACKUP_DIR}/`hostname -s` --user=root 2> ${DUMP_LOG} 
        mariabackup --backup -S {{ mariadb_socket }} --target-dir ${LOCAL_BACKUP_DIR}/`hostname -s` --user=root 2> ${DUMP_LOG} 
        EXIT=$?
        RC=$((RC+EXIT))
	echo "[`date '+%Y/%m/%d %T'`] "
	echo "[`date '+%Y/%m/%d %T'`] Zabbixサーバ起動"
        systemctl start zabbix-server.service
	echo "[`date '+%Y/%m/%d %T'`] "
        EXIT=$?
        RC=$((RC+EXIT))
        echo "[`date '+%Y/%m/%d %T'`] Mariabackup終了ステータス ${RC}"
        if [ ${EXIT} -eq 0 ]; then
                echo "[`date '+%Y/%m/%d %T'`] "
                echo "[`date '+%Y/%m/%d %T'`] バックアップデータをアーカイブ"
                cd ${LOCAL_BACKUP_DIR} && tar -cf ${BACKUP_NAME}/mariadb.tar `hostname -s`
                EXIT=$?
                RC=$((RC+EXIT))
                echo "[`date '+%Y/%m/%d %T'`] "
                echo "[`date '+%Y/%m/%d %T'`] mariadb-${DATE}.tarのハッシュ値を取得"
                cd ${LOCAL_BACKUP_DIR};sha512sum ${BACKUP_NAME}/mariadb.tar | \
                tee ${LOCAL_BACKUP_DIR}/${BACKUP_NAME}/sha512sum_mariadb-${DATE}.txt  
		### パスワードZIPにしながらリモートへ転送
	        # zip -P <<ZIPパスワード>> -mr - «圧縮対象ディレクトリ» | ssh «リモートホスト» "cat > «リモートでの書き出し先圧縮ファイルパス»"	
                cd ${LOCAL_BACKUP_DIR} && zip -P ${PASSWD} -mr ${BACKUP_NAME}.zip ${BACKUP_NAME} 
		RC=$?
		echo "[`date '+%Y/%m/%d %T'`] 終了ステータス　${RC}" 
		if [ ${RC} -eq 0 ]; then
			echo "[`date '+%Y/%m/%d %T'`] ${LOCAL_BACKUP_DIR}/${BACKUP_NAME}.zip にバックアップ完了" 
                	cd ${LOCAL_BACKUP_DIR} && rm -rf `hostname -s`
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
echo "[`date '+%Y/%m/%d %T'`] `basename $0`戻り値の合計：${RC}"
} | tee -a ${SCRIPT_LOG} 
# 全ての処理が完了するのを待ちます
wait
# debug code
#echo "[`date '+%Y/%m/%d %T'`] $1 1st" | tee -a ${TEST_LOG}
#sleep 10
#exit 0

### スクリプト終了メール
sleep 3
{
echo "`date`: `basename $0`"
cat ${SCRIPT_LOG} | grep "所要時間"
cat ${SCRIPT_LOG} | grep "戻り値の合計"
echo "戻り値が０以外の場合は、以下のスクリプトを確認"
echo ${SCRIPT_LOG}
echo ${DEBUG_LOG}
} | timeout 3 mail -s "[`hostname -s `]:`basename $0` Scrpt Work END" ${MAIL_ADDRESS}

