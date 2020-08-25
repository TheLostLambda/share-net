#/bin/bash

# Activate the bridging interface and assign a static IP
ip link set up $link
ip addr add $host dev $link

# Enable packet forwarding
sysctl net.ipv4.ip_forward=1

# Enable NAT for leaving packets
iptables -t nat -A POSTROUTING -o $wanlink -j MASQUERADE
# Forward packets coming from $link
iptables -I DOCKER-USER -i $link -j ACCEPT
# Forward packets that are part of an existing connection (forwards responses)
iptables -I DOCKER-USER -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

# Start dnsmasq for DHCP
dnsmasq -d -i $link -F $client,$client,1m  &

# Setup a trap to run cleanup before exiting
function cleanup {
    ip addr del $host dev $link
    ip link set down $link
    iptables -t nat -D POSTROUTING -o $wanlink -j MASQUERADE
    iptables -D DOCKER-USER -i $link -j ACCEPT
    iptables -D DOCKER-USER -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
}
trap cleanup EXIT

# Wait for dnsmasq to close
wait $!
