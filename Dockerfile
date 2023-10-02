FROM resin/aarch64-debian:stretch

ENV OPENSSL_FLAGS='no-idea no-mdc2 no-rc5 no-zlib enable-tlsext no-ssl2 no-ssl3 no-ssl3-method enable-rfc3779 enable-cms'

RUN echo "deb [trusted=yes] http://archive.debian.org/debian stretch main non-free contrib" > /etc/apt/sources.list && \
    echo 'deb-src [trusted=yes] http://archive.debian.org/debian/ stretch main non-free contrib'  >> /etc/apt/sources.list && \
    echo 'deb [trusted=yes] http://archive.debian.org/debian-security/ stretch/updates main non-free contrib'  >> /etc/apt/sources.list && \
 apt-get update     && \
    apt-get install -y    \
       build-essential git flex bison gperf python ruby git libfontconfig1-dev \
       dpkg-dev binutils gcc g++ libc-dev \
       curl

WORKDIR /tmp

RUN git clone https://github.com/eceolin/phantomjs && \
#git clone https://github.com/eceolin/phantomjs-files.git && \
 #   mv phantomjs-files phantomjs && \
    cd phantomjs           && \
    git checkout 1.9.8-wo-breakpad     && \
    git submodule init     && \
    git submodule update   && \
    apt-get source icu


# RUN git clone https://github.com/google/breakpad.git && \
#     cd breakpad && \
#     git checkout 3ea3af4

# RUN git clone https://chromium.googlesource.com/linux-syscall-support && \
#     cd linux-syscall-support && \
#     git checkout 9719c1e

#RUN cd phantomjs && \
 #   rm -r src/breakpad/src/client && \
 #   cp -r /tmp/breakpad/src/client ./src/breakpad/src/client && \
  #    rm -r ./src/breakpad/src/common && \
  #    cp -r /tmp/breakpad/src/common ./src/breakpad/src/common && \
   #   rm -r ./src/breakpad/src/google_breakpad && \
  #    cp -r /tmp/breakpad/src/google_breakpad ./src/breakpad/src/google_breakpad && \
  #    rm ./src/breakpad/src/third_party/lss/linux_syscall_support.h && \
  #    cp /tmp/linux-syscall-support/linux_syscall_support.h ./src/breakpad/src/third_party/lss/linux_syscall_support.h

RUN sudo chown -Rv _apt:root /var/cache/apt/archives/partial/ && \
    chmod -Rv 700 /var/cache/apt/archives/partial/

RUN cd phantomjs && \
    curl -L -O https://launchpad.net/debian/+archive/primary/+sourcefiles/openssl/1.0.1t-1+deb8u7/openssl_1.0.1t-1+deb8u7.dsc           && \
    curl -L -O https://launchpad.net/debian/+archive/primary/+sourcefiles/openssl/1.0.1t-1+deb8u7/openssl_1.0.1t.orig.tar.gz            && \
    curl -L -O https://launchpad.net/debian/+archive/primary/+sourcefiles/openssl/1.0.1t-1+deb8u7/openssl_1.0.1t-1+deb8u7.debian.tar.xz && \
    dpkg-source -x openssl_1.0.1t-1+deb8u7.dsc openssl-1.0.1t && \
    cd openssl-1.0.1t && \
    ./Configure --prefix=/usr --openssldir=/etc/ssl --libdir=lib ${OPENSSL_FLAGS} linux-generic64 && \
    make depend && make -j 4 && make install_sw

RUN echo "Building the static version of ICU library..." && \
    cd phantomjs/icu-57.1/source && \
    ./configure --prefix=/usr --enable-static --disable-shared && \
    make -j 4 && make install

RUN apt-get install libgtk2.0-dev

RUN echo "Compiling PhantomJS..." && \
    cd phantomjs && \
    ./build.sh --confirm
#binary is /tmp/phantomjs/bin/phantomjs

CMD ["/bin/bash"]