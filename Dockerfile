# syntax=docker/dockerfile:1

# Fetch, configure and build secp256k1 library.
FROM alpine/git AS secp256k1-source
RUN git clone https://github.com/bitcoin-core/secp256k1

FROM alpine as secp256k1-config
COPY --from=secp256k1-source /git/secp256k1 /opt/secp256k1
WORKDIR /opt/secp256k1
RUN apk --update upgrade && apk add autoconf automake libtool
RUN ./autogen.sh

FROM alpine as secp256k1-build
COPY config.site /usr/local/share/config.site
COPY --from=secp256k1-config /opt/secp256k1 /opt/secp256k1
WORKDIR /opt/secp256k1
RUN apk --update upgrade && apk add g++ make
RUN ./configure --prefix=/usr/local --enable-module-recovery --disable-benchmark --disable-tests --disable-shared && make install

# Fetch, configure and build LibBTC using secp256k1 as dependency.

FROM alpine/git AS libbtc-source
COPY libbtc/configure.ac.patch /git
COPY libbtc/Makefile.am.patch /git
RUN apk --update upgrade && apk add patch
RUN git clone https://github.com/libbtc/libbtc && \
    cd libbtc && \
    patch -uN configure.ac < ../configure.ac.patch && \
    patch -uN Makefile.am < ../Makefile.am.patch

FROM alpine as libbtc-config
COPY --from=libbtc-source /git/libbtc /opt/libbtc
WORKDIR /opt/libbtc
RUN apk --update upgrade && apk add autoconf automake libtool
RUN ./autogen.sh

FROM alpine as libbtc-build
COPY config.site /usr/local/share/config.site
COPY --from=secp256k1-build /usr/local /usr/local
COPY --from=libbtc-config /opt/libbtc /opt/libbtc
WORKDIR /opt/libbtc
RUN apk --update upgrade && apk add g++ make
RUN ./configure --prefix=/usr/local --disable-wallet --disable-net --disable-shared && make install

# To build the btc library only with not command line interface use `--disable-tools`.

# Final targets

FROM alpine as secp256k1
COPY --from=secp256k1-build /usr/local /usr/local

FROM alpine
COPY --from=libbtc-build /usr/local /usr/local
ENTRYPOINT ["/usr/local/bin/bitcointool"]
