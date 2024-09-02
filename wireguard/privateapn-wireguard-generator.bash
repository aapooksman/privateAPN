serveraddress="123.123.123.123"

for i in {001..005};
do
	j=$((10#$i)) # remove leading zeros
 
	echo "generating SIM $j conf"

	serverprivkey=$(wg genkey)
	serverpubkey=$(echo $serverprivkey | wg pubkey)

	clientprivkey=$(wg genkey)
	clientpubkey=$(echo $clientprivkey | wg pubkey)

	cat <<EOF > SIM"$i"Server.wg.conf
#SIM $i Server
[Interface]
Address    = 10.222.$j.254/24
ListenPort = 52$i
#PublicKey = $serverpubkey
Privatekey = $serverprivkey
Table      = off
PostUp     = ip rule flush table $j
PostUp     = ip rule add from 10.222.0.$j/32 table $j
PostUp     = ip route add default via 10.222.$j.$j table $j

#SIM $i Client
[Peer]
PublicKey   = $clientpubkey
AllowedIPs  = 10.222.$j.$j/32, 0.0.0.0/0
EOF
	cat <<EOF > SIM"$i"Client.wg.conf
#SIM $i Client
[Interface]
#PublicKey = $clientpubkey
Privatekey = $clientprivkey
Address    = 10.222.$j.$j/32
Table      = off
PostUp     = ip -4 route add 10.222.0.$j/32 dev SIM${i}Client.wg

#SIM $i Server
[Peer]
PublicKey = $serverpubkey
AllowedIPs = 0.0.0.0/0
Endpoint = $serveraddress:52$i
PersistentKeepalive = 20
EOF

done
