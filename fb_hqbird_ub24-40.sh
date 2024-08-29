#!/bin/bash

# source: https://raw.githubusercontent.com/IBSurgeon/firebirdlinuxinstall/06c271f46fbf46d1186c9a28b6fbe383423c7a90/ubuntu24/fb_hqbird_ub24-40.sh
# Please contact IBSurgeon with any question regarding this script: support@ib-aid.com
# This script is provided AS IS, without any warranty. 
# This script is licensed under IDPL https://firebirdsql.org/en/initial-developer-s-public-license-version-1-0/

FB_VER=4.0
FTP_URL="https://cc.ib-aid.com/download/distr"
TMP_DIR=$(mktemp -d)
OLD_DIR=$(pwd -P)

download_file(){
    url=$1
    tmp=$2
    name=$3
    fname=$(basename -- "$url")

    echo "Downloading $name..."
    curl $url --output $tmp/$fname --progress-bar

    case $? in
      0)  echo "OK";;	  
      23) echo "Write error"
          exit 0;;
      67) echo "Wrong login / password"
              exit 0;;
      78) echo "File $fb_url/$fb_file $does not exist on server"
          exit 0;;
    esac
}

echo "vm.max_map_count = 256000" >> /etc/sysctl.conf
sysctl -p

apt update
apt install --no-install-recommends -y net-tools wget unzip gettext libncurses6 curl tar tzdata locales sudo mc xz-utils file libtommath1 libicu74 openjdk-8-jre
ln -s libtommath.so.1 /usr/lib/x86_64-linux-gnu/libtommath.so.0
ln -s libncurses.so.6 /usr/lib/x86_64-linux-gnu/libncurses.so.5
locale-gen "en_US.UTF-8"

## Firebird & Hqbird download
download_file $FTP_URL/$FB_VER/fb.tar.xz $TMP_DIR "FB installer"
#download_file $FTP_URL/$FB_VER/conf.tar.xz $TMP_DIR "FB config files"
download_file $FTP_URL/amvmon.tar.xz $TMP_DIR "AMV & MON installer"
download_file $FTP_URL/distrib.tar.xz $TMP_DIR "DG installer"
download_file $FTP_URL/hqbird.tar.xz $TMP_DIR "HQbird installer"

echo Extracting FB installer ==================================================

mkdir $TMP_DIR/fb $TMP_DIR/conf
tar xvf $TMP_DIR/fb.tar.xz -C $TMP_DIR/fb --strip-components=1 > /dev/null
#tar xvf $TMP_DIR/conf.tar.xz -C $TMP_DIR/conf  > /dev/null
cd $TMP_DIR/fb

echo Running FB installer =====================================================

sed -i 's/libncurses.so.5/libncurses.so.6/g' install.sh
yes 'masterkey' | ./install.sh
#./install.sh -silent
cd $OLD_DIR
#cp -rf $TMP_DIR/conf/*.conf /opt/firebird

echo Installing HQbird ========================================================

if [ ! -d /opt/hqbird ]; then 
	echo "Creating directory /opt/hqbird"
        mkdir /opt/hqbird
    else
	echo "Directory /opt/hqbird already exists"
fi

tar xvf $TMP_DIR/amvmon.tar.xz -C /opt/hqbird > /dev/null
tar xvf $TMP_DIR/distrib.tar.xz -C /opt/hqbird > /dev/null
tar xvf $TMP_DIR/hqbird.tar.xz -C /opt/hqbird > /dev/null

cp /opt/hqbird/amv/fbccamv.service /opt/hqbird/mon/init/systemd/fbcclauncher.service /opt/hqbird/mon/init/systemd/fbcctracehorse.service /opt/hqbird/init/systemd/hqbird.service /lib/systemd/system
chmod -x /lib/systemd/system/fbcc*.service
systemctl daemon-reload

if [ ! -d /opt/hqbird/outdataguard ]; then 
	echo "Creating directory /opt/hqbird/outdataguard"
	mkdir /opt/hqbird/outdataguard
    else
        echo "Directory /opt/hqbird/outdataguard already exists"
fi
echo "Running HQbird setup"
sh /opt/hqbird/hqbird-setup
rm -f /opt/firebird/plugins/libfbtrace2db.so 2 > /dev/null

echo Registering HQbird ========================================================

mkdir -p /opt/hqbird/conf/agent/servers/hqbirdsrv
cp -R /opt/hqbird/conf/.defaults/server/* /opt/hqbird/conf/agent/servers/hqbirdsrv
sed -i 's#server.installation =.*#server.installation=/opt/firebird#g' /opt/hqbird/conf/agent/servers/hqbirdsrv/server.properties
sed -i 's#server.bin.*#server.bin = ${server.installation}/bin#g' /opt/hqbird/conf/agent/servers/hqbirdsrv/server.properties

java -Djava.net.preferIPv4Stack=true -Djava.awt.headless=true -Xms128m -Xmx192m -XX:+UseG1GC -jar /opt/hqbird/dataguard.jar -config-directory=/opt/hqbird/conf -default-output-directory=/opt/hqbird/outdataguard/ > /dev/null &
sleep 5
java -jar /opt/hqbird/dataguard.jar -register -regemail="linuxauto@ib-aid.com" -regpaswd="L8ND44AD" -installid=/opt/hqbird/conf/installid.bin -unlock=/opt/hqbird/conf/unlock -license="T"

pkill -f dataguard.jar
sleep 5

echo Registering test database =================================================

mkdir -p /opt/hqbird/conf/agent/servers/hqbirdsrv/databases/test_employee_fdb/
cp -R /opt/hqbird/conf/.defaults/database4/* /opt/hqbird/conf/agent/servers/hqbirdsrv/databases/test_employee_fdb/
java -jar /opt/hqbird/dataguard.jar -regdb="/opt/firebird/examples/empbuild/employee.fdb" -srvver=3 -config-directory="/opt/hqbird/conf" -default-output-directory="/opt/hqbird/outdataguard"
rm -rf /opt/hqbird/conf/agent/servers/hqbirdsrv/databases/test_employee_fdb/

sed -i 's/db.replication_role=.*/db.replication_role=switchedoff/g' /opt/hqbird/conf/agent/servers/hqbirdsrv/databases/*/database.properties
sed -i 's/job.enabled.*/job.enabled=false/g' /opt/hqbird/conf/agent/servers/hqbirdsrv/databases/*/jobs/replmon/job.properties
sed -i 's/^#\s*RemoteAuxPort.*$/RemoteAuxPort = 3059/g' /opt/firebird/firebird.conf
#sed -i 's/ftpsrv.homedir=/ftpsrv.homedir=\/opt\/database/g' /opt/hqbird/conf/ftpsrv.properties
sed -i 's/ftpsrv.passivePorts=40000-40005/ftpsrv.passivePorts=40000-40000/g' /opt/hqbird/conf/ftpsrv.properties
chown -R firebird:firebird /opt/hqbird /opt/firebird/firebird.conf /opt/firebird/databases.conf

systemctl enable hqbird
systemctl restart hqbird
systemctl disable fbccamv fbcclauncher fbcctracehorse
systemctl stop fbccamv fbcclauncher fbcctracehorse

# cleanup
if [ -d $TMP_DIR ]; then rm -rf $TMP_DIR; fi

## SCRIPT FROM IBSURGEON END HERE

chown firebird:firebird /opt/firebird

cat > /opt/firebird/firebird.conf << 'EOF'
#Configuration for Firebird 4 HQbird SuperServer (64 bit)

ServerMode = Super
DefaultDbCachePages = 10K # pages (SuperServer) - increase pages in databases.conf, not here

LockMemSize = 20M # bytes (SuperServer)
LockHashSlots = 40099 # slots

TempCacheLimit = 256M
MaxUnflushedWrites = -1 # default for posix (non-Windows)
MaxUnflushedWriteTime = -1 # default for posix (non-Windows)
UseFileSystemCache = true
RemoteServicePort = 3050
RemoteAuxPort = 3051
InlineSortThreshold = 16384 # use REFETCH plan for big sortings

DataTypeCompatibility = 2.5

ExtConnPoolSize = 64 # external connections pool size
ExtConnPoolLifeTime = 3600 # seconds

#set DataTypeCompatibility according Migration Guide https://ib-aid.com/download/docs/fb4migrationguide.html
#DataTypeCompatibility =
#WireCryptPlugin = ChaCha64, ChaCha, Arc4
WireCrypt = Disabled
#WireCompression = false
#RemoteAuxPort = 0
#authentication plugin setup
#Recommendation - use SELECT * FROM SEC$USERS
#to check that you have users for all plugins
AuthClient = Srp256, Srp
AuthServer = Srp256
UserManager = Srp

#MaxIdentifierByteLength = 252
#MaxIdentifierCharLength = 63
#DefaultTimeZone =
#SnapshotsMemSize = 64K # bytes
#TipCacheBlockSize = 4M # bytes

#HQbird
TempSpaceLogThreshold = 1280M # HQBird - log big sortings
ParallelWorkers = 1 # HQBird - default parallel threads
MaxParallelWorkers = 64 # HQbird - parallel threads for sweep, backup, restore
MaxTempBlobs = 10000 # HQBird - allow up to 10000 temp blobs in blob_append
BlobTempSpace = 1 # HQBird - cache PSQL Blobs to temp space
#HQbirdVersionString = true # HQBird - show HQbird version (disable for dbExpress)
LeftJoinConversion=false # advanced optimization of joins is off
EOF

systemctl restart firebird.service

ln -s /opt/firebird/bin/gbak /bin/gbak && ln -s /opt/firebird/bin/gstat /bin/gstat && ln -s /opt/firebird/bin/gfix /bin/gfix && ln -s /opt/firebird/bin/nbackup /bin/nbackup && ln -s /opt/firebird/bin/gsec /bin/gsec && ln -s /opt/firebird/bin/isql /bin/isql

echo "Confirme as configurações do /opt/firebird.conf"
echo "Gere a senha:"
echo "isql -user sysdba -password masterkey security.db"
echo "alter user SYSDBA password 'NOVASENHA' using plugin Srp;"
