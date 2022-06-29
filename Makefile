GITHUB_OWNER=wybrenkoelmans
PHP_VERSION=8.1
ALPINE_VERSION=3.16

build:
	cd php && git clean -f
	cp *.patch php/${PHP_VERSION}/alpine${ALPINE_VERSION}/fpm/
	cd php/${PHP_VERSION}/alpine${ALPINE_VERSION}/fpm/;\
	git fetch;\
	git reset --hard remotes/origin/master;\
	patch -p4 Dockerfile < Dockerfile.patch;\
	docker build -t ghcr.io/${GITHUB_OWNER}/php:${PHP_VERSION}-fpm-alpine${ALPINE_VERSION} .

push:
	docker push ghcr.io/${GITHUB_OWNER}/php:${PHP_VERSION}-fpm-alpine${ALPINE_VERSION}
