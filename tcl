#!/bin/sh
. /etc/init.d/tc-functions

P=postfix
V=3.3.19
T=/tmp/"${P}"
Z="${P}".tcz

build() {
	# Dependencies
	tce-load -i db-dev openssl-dev	# TCL shall complain if already loaded, but no harm
	# Tweak 'makedefs' for TCL (/usr/include/db/db.h => /usr/local/include)
	sed -i 's|-f /usr/include/db/db.h|-f /usr/local/include/db.h|g' makedefs
	sed -i 's|CCARGS -I/usr/include/db|CCARGS -I/usr/local/include|g' makedefs
	# Build
	make tidy
	make makefiles shared=yes CCARGS='-DUSE_SASL_AUTH -DDEF_SERVER_SASL_TYPE=\"dovecot\" -DUSE_TLS -lssl -lcrypto'
	make
	[ $? -eq 0 ] && echo "${BLUE}Build done${NORMAL}"
}
eAbort() {
	echo "${RED}${1}${NORMAL}"
	exit 1
}
addf() {	# src dst
	local D=`dirname "${1}"`
	rm -rf "${T}/${D}"
	mkdir -p "${T}"/"${D}"
	echo "${2}" > "${T}/${1}"
	chmod +x "${T}/${1}"
}

instmp() {
	local D=`pwd`
	[ ! -x bin/postfix ] && eAbort "Did you build?"
	[ -d "${T}" ] && rm -rf "${T}"
	mkdir -p "${T}"
	instdir lib lib/postfix
	instdir libexec libexec/postfix
	instdir bin sbin
	cd "${T}"/usr
	mkdir -p bin
	cd bin
	ln -s ../sbin/sendmail mailq
	ln -s ../sbin/sendmail newaliases
	cd "${D}"
}

instdir() {	# src dst
	local D="${T}"/usr/"${2}"
	[ -d "${D}" ] && rm -rf "${D}"
	mkdir -p "${D}"
	cp "${1}"/* "${D}"/
	strip "${D}"/* 2>/dev/null
}

instcz() {
	cd /tmp
	[ ! -f "${Z}" ] && eAbort "${Z} not found (did you made TCZ?)"
	md5sum "${Z}" > "${Z}".md5.txt
	echo 'db.tcz' > "${Z}".dep
	cp -f "${Z}"* /etc/sysconfig/tcedir/optional/
	echo "${BLUE}Done (check if it's in the 'onboot.lst'${NORMAL}"
}

mkInstalled() {
	cat << DATA
#!/bin/sh
# Place here code to be executed on TCZ load
DATA
}

mkService() {
	cat << DATA
#!/bin/sh
case "\${1}" in
    start)	${P} start;;
    stop)   ${P} stop;;
    reload)	${P} reload;;
    status) pidof -o %PPID ${P};;
    *)      exit 1;;
esac
DATA
}

mktcz() {
	[ ! -d "${T}" ] && eAbort "${T} not found (did you build?)"
	instmp
	cd /tmp
	addf etc/init.d/services/"${P}" "`mkService`"
	#addf usr/local/tce.installed/"${P}" "`mkInstalled`"
	#mkdir -p "${T}"/var/mail
	mkdir -p "${T}"/var/spool/postfix
	[ -f "${Z}" ] && rm -f "${Z}"*
	mksquashfs "${P}"/ "${Z}"
}

usage() {
	cat << HLP
usage: ${1} cmd [cmd] ...
cmd:   b  build
       e  set /tmp/${P}
       t  make TCZ
       i  install TCZ
example:
       ${1} b t i  (build, make TCZ, install it)
       ${1} t      (make TCZ only)
HLP
	exit 1
}

[ ! $1 ] && usage `basename $0`
while [ $1 ]; do
	case $1 in
		b) build;;
		c) make clean;;
		e) instmp;;
		i) instcz;;
		t) mktcz;;
		*) usage;;
	esac
	shift
done
