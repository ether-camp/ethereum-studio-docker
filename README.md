# Ethereum Studio Dockerfile

**The image is broken since the ethereum sandbox doesn't support the latest solc. Fixing it.**

The repo contains a dockerfile to build Ethereum Studio docker.

Run the commands to build the docker:
```
$ git clone https://github.com/ether-camp/ethereum-studio-docker
$ cd ethereum-studio-docker
$ sudo docker build --no-cache . -t ethereum-studio
```

To run the new image:
```
$ sudo docker run -d -e MODE=standalone ethereum-studio
```

Or you can run the docker hub image:
```
$ sudo docker pull ethercamp/ethereum-studio
$ sudo docker run -d -e MODE=standalone ethercamp/ethereum-studio
```
