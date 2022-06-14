#!/usr/bin/bash

OPENSSL_TAR_GZ=openssl-1.1.1o.tar.gz
OPENSSL_DIR=openssl-1.1.1o
REMOTE_SRC=https://www.openssl.org/source/

SSL_DIR=/usr/local/ssl
BINARIES_SCRIPT=/etc/profile.d/openssl.sh

is_installed () {

    if yum list installed "$@" >/dev/null 2>&1; then
        true
    else
        false
    fi
}

if [ "$EUID" -ne 0 ]
    then echo "Please run as root"
    exit
fi

echo "Installing Dependencies"

#yum -y update

# MAKE
if is_installed 'make'; then
    echo "make ... already installed"
else
    yum install make -y
fi

# DEVELOPMENT TOOLS
yum group install 'Development Tools' -y

# PERL-CORE
if is_installed 'perl-core'; then
    echo "perl-core ... already installed"
else
    yum install perl-core -y
fi


# ZLIB_DEVEL
if is_installed 'zlib-devel'; then
    echo "zlib-devel ... already installed"
else
    yum install zlib-devel -y
fi


# WGET
if is_installed 'wget'; then
    echo "wget ... already installed"
else
    yum install wget -y
fi

# DOWNLOAD OPENSSL
cd /usr/local/src/
if [[ -f "$OPENSSL_TAR_GZ" ]]; then
    echo "$OPENSSL_TAR_GZ ... already exists"
else
    wget $REMOTE_SRC$OPENSSL_TAR_GZ
fi

if [[ -d "$OPENSSL_DIR" ]]; then
    echo "$OPENSSL_DIR ... already exists"
else
    echo -n "Extracting ..."
    tar -xf $OPENSSL_TAR_GZ
    echo " done"
fi

# INSTALL OPENSSL

cd $OPENSSL_DIR

if [[ -d "$SSL_DIR" ]]; then
    echo "$SSL_DIR ... already exists. Probably installed."
else
    ./config --prefix=$SSL_DIR --openssldir=$SSL_DIR shared zlib

    make
    make test
    make install
fi

# LINK LIBRARIES

if [[ -d "$SSL_DIR/lib" ]]; then
    if [[ -f "/etc/ld.so.conf.d/$OPENSSL_DIR.conf" ]]; then
        echo "libraries conf ... already exists"
    else
        echo "$SSL_DIR/lib" > /etc/ld.so.conf.d/$OPENSSL_DIR.conf
        ldconfig -v
    fi
else
    echo "$SSL_DIR/lib ... not found. Probably openssl uninstalled."
fi

# CONFIGURE BINARY

if [[ -f "/usr/bin/openssl" ]]; then
    mv /usr/bin/openssl /usr/bin/openssl.BEKUP
    echo "Backup of /usr/bin/openssl -> /usr/bin/openssl.BEKUP"
else
    echo "/usr/bin/openssl ... already moved"
fi

if [[ -f "$BINARIES_SCRIPT" ]]; then
    echo "$BINARIES_SCRIPT ... already exists"
else

    echo "#Set OPENSSL_PATH"                   > $BINARIES_SCRIPT
    echo "OPENSSL_PATH=\"/usr/local/ssl/bin\"" >> $BINARIES_SCRIPT
    echo "export OPENSSL_PATH"                 >> $BINARIES_SCRIPT
    echo "PATH=\$PATH:\$OPENSSL_PATH"          >> $BINARIES_SCRIPT
    echo "export PATH"                         >> $BINARIES_SCRIPT

    chmod +x $BINARIES_SCRIPT

    echo "$BINARIES_SCRIPT added ... run with: source $BINARIES_SCRIPT"
fi

echo "DONE"
