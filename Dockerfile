FROM debian:stretch
MAINTAINER Richard Kojedzinszky <krichy@nmdps.net>

ENV OTRS_VERSION=5.0.18 \
	OTRS_MD5SUM=c7da745c8b27fe310e2e4a5c0af5d5b8 \
	OTRS_URL_PREFIX=http://ftp.otrs.org/pub/otrs/

RUN apt-get update && apt-get dist-upgrade -f -y && \
	apt-get install -f -y apache2 libapache2-mod-perl2 libdbd-mysql-perl libdbd-pg-perl \
	libtimedate-perl libnet-dns-perl libnet-ldap-perl libio-socket-ssl-perl \
	libpdf-api2-perl libsoap-lite-perl libtext-csv-xs-perl libjson-xs-perl \
	libapache-dbi-perl libxml-libxml-perl libxml-libxslt-perl libyaml-perl \
	libarchive-zip-perl libcrypt-eksblowfish-perl libencode-hanextra-perl \
	libmail-imapclient-perl libtemplate-perl libcrypt-ssleay-perl wget supervisor cron && \
	rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

RUN wget -O /tmp/otrs-${OTRS_VERSION}.tar.gz ${OTRS_URL_PREFIX}/otrs-${OTRS_VERSION}.tar.gz && \
	test ${OTRS_MD5SUM} = $(md5sum /tmp/otrs-${OTRS_VERSION}.tar.gz | awk '{print $1}') && \
	tar xzf /tmp/otrs-${OTRS_VERSION}.tar.gz -C /opt && rm -f /tmp/otrs-${OTRS_VERSION}.tar.gz && \
	mv /opt/otrs-${OTRS_VERSION} /opt/otrs && \
	perl /opt/otrs/bin/otrs.CheckModules.pl

COPY Config.pm /opt/otrs/Kernel/

RUN useradd -d /opt/otrs -c 'OTRS user' otrs && \
	adduser otrs www-data && \
	ln -sf /opt/otrs/scripts/apache2-httpd.include.conf /etc/apache2/conf-enabled/zzz_otrs.conf && \
	a2enmod perl && \
	a2enmod deflate && \
	a2enmod filter && \
	a2enmod headers && \
	/opt/otrs/bin/otrs.SetPermissions.pl --web-group=www-data && \
	cd /opt/otrs/var/cron && for foo in *.dist; do cp $foo `basename $foo .dist`; done && \
	su otrs -c "/opt/otrs/bin/Cron.sh start" && \
	mkdir /data

COPY entrypoint.sh /
COPY supervisord.conf /etc/

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 80

VOLUME /data

CMD ["/usr/bin/supervisord"]
