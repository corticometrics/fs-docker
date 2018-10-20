all: fs-build fs-run

fs-build:
	cd ./build && docker build -t corticometrics/freesurfer-build .

fs-run:
	cd ./run && docker build -t corticometrics/freesurfer-run .
