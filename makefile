all: fs-dev-xenial-build fs-dev-xenial-recon-all

fs-dev-xenial-build:
	docker build -f dockerfile.fs-dev-xenial-build -t corticometrics/fs-dev-xenial-build .

fs-dev-xenial-recon-all:
	docker build -f dockerfile.fs-dev-xenial-recon-all -t corticometrics/fs-dev-xenial-recon-all .
