web-page-root = /usr/local/aolserver/servers/rgrjr/pages
pages = index.html

all:

install:
	install -m 444 ${pages} ${web-page-root}