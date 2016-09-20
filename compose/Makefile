VER=2.1-3rc3
BASEVER=1

checkout:
	mkdir -p unifield
	bzr checkout --lightweight -r uf$(VER) lp:unifield-server unifield/server
	bzr checkout --lightweight -r uf$(VER) lp:unifield-web unifield/web

build: checkout
	# The base image does not include any Unifield code
	# so we put a simpler base version on it.
	docker build -f Dockerfile-base -t unifield/base:$(BASEVER) .
	docker push unifield/base:$(BASEVER)
	docker build -f Dockerfile-web -t unifield/web:$(VER) .
	docker push unifield/web:$(VER)
	docker build -f Dockerfile-server -t unifield/server:$(VER) .
	docker push unifield/server:$(VER)
