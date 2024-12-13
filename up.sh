getversion(){
curl -fsSL https://api.github.com/repos/$1/releases/latest | grep -o '"tag_name": ".*"' | head -n 1 | sed 's/"//g;s/v//g' | sed 's/tag_name: //g' | sed 's/release-//g'
}
echo "ARIA2_VER=$(getversion aria2/aria2)
ZLIB='https://github.com/madler/zlib/releases/download/v$(getversion madler/zlib)/zlib-$(getversion madler/zlib).tar.gz'
C_ARES='https://github.com/c-ares/c-ares/releases/download/v$(getversion c-ares/c-ares)/c-ares-$(getversion c-ares/c-ares).tar.gz'
EXPAT='https://github.com/libexpat/libexpat/releases/download/$(getversion libexpat/libexpat)/expat-$(echo "$(getversion libexpat/libexpat)" | head -n 1 | sed 's/_/./g' | sed 's/R.//g').tar.bz2'
LIBSSH2='https://github.com/libssh2/libssh2/releases/download/$(getversion libssh2/libssh2)/$(getversion libssh2/libssh2).tar.gz'
OPENSSL='https://github.com/openssl/openssl/releases/download/$(getversion openssl/openssl)/$(getversion openssl/openssl).tar.gz'
SQLITE3='https://sqlite.org/$(curl -fsSL https://sqlite.org/download.html | grep -o '..../sqlite-autoconf-.*.tar.gz' | head -n 1)'
GMP_VER='$(curl -s https://gmplib.org | grep -oP 'href="//gmplib\.org/download/gmp/gmp-\d.*\.tar\.xz"' | head -n 1 | sed 's|href="//|https://|; s|"||')'
JEMALLOC='https://github.com/jemalloc/jemalloc/releases/download/$(getversion jemalloc/jemalloc)/jemalloc-$(getversion jemalloc/jemalloc).tar.bz2'" > dependences