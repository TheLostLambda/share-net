# Build on a small alpine image
FROM alpine:latest

# Update all packages and install some packages
RUN apk update && apk upgrade && apk add iptables dnsmasq bash

# The environment variables describing the hardware and addresses to be bridged
ENV link eth0
ENV wanlink wlan0
ENV host 10.20.30.1/24
ENV client 10.20.30.2

# Copy over the network-sharing script and run it with bash
COPY share.sh .
CMD ["bash", "./share.sh"]
