getversion(){
curl -fsSL https://api.github.com/repos/$1/releases | grep -o '"tag_name": ".*"' | head -n 1 | sed 's/"//g;s/v//g' | sed 's/tag_name: //g' | sed 's/release-//g'
}
echo "ARIA2_VER=$(getversion aria2/aria2)
ZLIB='https://www.zlib.net/zlib-1.2.11.tar.gz'
C_ARES='https://github.com/c-ares/c-ares/releases/download/$(getversion c-ares/c-ares)/$(echo "$(getversion c-ares/c-ares)" | head -n 1 | sed 's/_/./g' | sed 's/ca/c-a/g').tar.gz'
EXPAT='https://github.com/libexpat/libexpat/releases/download/$(getversion libexpat/libexpat)/expat-$(echo "$(getversion libexpat/libexpat)" | head -n 1 | sed 's/_/./g' | sed 's/R.//g').tar.bz2'
LIBSSH2='https://github.com/libssh2/libssh2/releases/download/$(getversion libssh2/libssh2)/$(getversion libssh2/libssh2).tar.gz'
OPENSSL='https://www.openssl.org/source/$(curl -fsSL https://www.openssl.org/source/ | grep -o '"openssl-1.*.tar.gz"' | head -n 1 | sed 's/"//g')'
SQLITE3='https://sqlite.org/$(curl -fsSL https://sqlite.org/download.html | grep -o '..../sqlite-autoconf-.*.tar.gz' | head -n 1)'
JEMALLOC='https://github.com/jemalloc/jemalloc/releases/download/$(getversion jemalloc/jemalloc)/jemalloc-$(getversion jemalloc/jemalloc).tar.bz2'" > dependences

git config --global user.email "actions@github.com"
git config --global user.name "actions"
echo "$(date "+%Y%m%d-%H%M")" > update.txt
git add . && git commit -m "$(date "+%Y%m%d")" && git push && echo "更新完毕!!!" || echo "暂无更新!!!"
echo "======================="
