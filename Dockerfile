FROM alpine:3.4

# Install run-time deps
RUN apk --no-cache add fontconfig libstdc++
# Install build-time deps
RUN apk --no-cache add --virtual .bdeps alpine-sdk fontconfig-dev git python perl linux-headers curl gperf bison ruby flex


RUN curl http://download.icu-project.org/files/icu4c/57.1/icu4c-57_1-src.tgz | tar xz && \
    (cd icu/source && ./configure --prefix=/usr --enable-static --disable-shared && make && make install) && \
    git clone -b OpenSSL_1_0_1-stable https://github.com/openssl/openssl.git && \
    (cd openssl && \
        ./Configure --prefix=/usr --openssldir=/etc/ssl --libdir=lib no-idea no-mdc2 no-rc5 no-zlib enable-tlsext no-ssl2 no-ssl3 no-ssl3-method enable-rfc3779 enable-cms linux-x86_64 && \
        make depend && make && make install) && \
    git clone -b 2.1 https://github.com/ariya/phantomjs.git 
RUN du -sh /
RUN (cd phantomjs && \
        git submodule init && git submodule update && \
        (cd src/qt/qtbase && git cherry-pick -n 813f468a14fb84af43c1f8fc0a1430277358eba2) && \
        (cd src/qt/qtwebkit && git remote add ncopa https://github.com/ncopa/qtwebkit.git && git fetch ncopa && git cherry-pick -n 4742c38d9af3548b3720e67f38c48124efda01b5) && \
        python build.py --confirm --release --qt-config="-no-pkg-config" --git-clean-qtbase --git-clean-qtwebkit && \
        cp bin/phantomjs /usr/local/bin) && \
    adduser -D phantom && \
    rm -rf /phantomjs /icu /usr/include 
RUN du -sh /
RUN apk del .bdeps && \
RUN du -sh /
USER phantom
WORKDIR phantomjs
# Expose the ports for nginx
EXPOSE 80 443



ENTRYPOINT ["/usr/local/bin/phantomjs"]
CMD ["--help"]
