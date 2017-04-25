#!/bin/sh

relocate ()
{
	src="$1"
	dst="$2"

	if [ ! -L "$src" ]; then
		if [ ! -e "$dst" ]; then
			mv "$src" "$dst"
		else
			rm -rf "$src"
		fi
		ln -sf "$dst" "$src"
	fi
}

relocate /opt/otrs/Kernel/Config/Files /data/Kernel-Config-Files
relocate /opt/otrs/var/article /data/var-article
relocate /opt/otrs/var/log /data/var-log
relocate /opt/otrs/var/stats /data/var-stats
relocate /opt/otrs/var/spool /data/var-spool

cat <<EOF > /opt/otrs/Kernel/DBConfig.pl
{
	DATABASE_TYPE => '${DATABASE_TYPE}',
	DATABASE_HOST => '${DATABASE_HOST}',
	DATABASE_NAME => '${DATABASE_NAME}',
	DATABASE_USER => '${DATABASE_USER}',
	DATABASE_PASSWORD => '${DATABASE_PASSWORD}',
};
EOF

chown root:root /opt/otrs/Kernel/DBConfig.pl
chmod 644 /opt/otrs/Kernel/DBConfig.pl

exec "$@"
