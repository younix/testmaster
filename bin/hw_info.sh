#!/bin/sh

set -eu
usage() {
        echo "hw_info.sh host" > /dev/stderr
	echo "    host    the hostname of the target machine" > /dev/stderr
        exit 1
}

[ "$#" -eq "1" ] || usage

host=$1
dmesg=$(mktemp)
sysctl=$(mktemp)
ifconfig=$(mktemp)
usbdevs=$(mktemp)
pcidump=$(mktemp)

ssh root@$host 'cat /var/run/dmesg.boot' > $dmesg
ssh root@$host sysctl > $sysctl
ssh root@$host ifconfig > $ifconfig
ssh root@$host 'usbdevs -vv' > $usbdevs
ssh root@$host 'pcidump -v' > $pcidump

cat <<- EOF
<!doctype html>
<html lang="en-US">
<head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width">
        <link rel="stylesheet" type="text/css" href="style.css">
	<style>
pre {
	white-space: pre-wrap;
	width: 80ch;
	word-wrap: anywhere;
}
	</style>
        <title>$host info</title>
</head>
<body>

<h1><em>Open</em>BSDLab - $host info</h1>

<nav>
<a href="index.html">Home</a>
<a href="otx-config.html">otx config</a>
<a href="newuser.html">new user</a>
<a href="ssh_config.html">ssh_config</a>
<a href="faq.html">faq</a>
<hr></nav>

<p>Automatically gathered information on $host.<br>
<em>last updated: $(date "+%Y-%m-%d %H:%M:%S")</em></p>

<nav>
<a href="#dmesg">dmesg</a>
<a href="#sysctl">sysctl</a>
<a href="#ifconfig">ifconfig</a>
<a href="#usbdevs">usbdevs</a>
<a href="#pcidump">pcidump</a>
</nav>

<h2 id="dmesg">dmesg</h2>
<pre>$(cat $dmesg)</pre>

<h2 id="sysctl">sysctl</h2>
<pre>$(cat $sysctl)</pre>

<h2 id="ifconfig">ifconfig</h2>
<pre>$(cat $ifconfig)</pre>

<h2 id="usbdevs">usbdevs</h2>
<pre>$(cat $usbdevs)</pre>

<h2 id="pcidump">pcidump</h2>
<pre>$(cat $pcidump)</pre>

<footer><hr><a href="https://www.genua.de/impressum.html">Impressum</a></footer>

</body>
</html>
EOF

rm $dmesg $sysctl $ifconfig $usbdevs $pcidump
