#!/bin/bash

bash <(curl -fsSL https://raw.githubusercontent.com/IBSurgeon/firebirdlinuxinstall/06c271f46fbf46d1186c9a28b6fbe383423c7a90/ubuntu24/fb_hqbird_ub24-40.sh)

echo "" && echo "Iniciando configurações adicionais"
sleep 5

systemctl disable fbccamv fbcclauncher fbcctracehorse
systemctl stop fbccamv fbcclauncher fbcctracehorse

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

echo ""
echo "-------------------------------------------------------'
echo "Confirme as configurações em /opt/firebird/firebird.conf"
echo "Troque a senha sysdba:"
echo "isql -user sysdba -password masterkey security.db"
echo "alter user SYSDBA password 'NOVASENHA' using plugin Srp;"
