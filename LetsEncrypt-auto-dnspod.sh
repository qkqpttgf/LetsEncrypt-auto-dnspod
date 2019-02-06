#!/usr/bin/env bash

echo
echo "###############################################################"
echo "# USE dnspod API Auto obtain&renew Let’s Encrypt certificate  #"
echo "# Only CentOS7 & RAM>128                                      #"
echo "# Author: ysun <qkqpttgf@gmail.com>                           #"
echo "# Github: https://github.com/qkqpttgf/LetsEncrypt-auto-dnspod #"
echo "###############################################################"
echo "wget -N https://github.com/qkqpttgf/LetsEncrypt-auto-dnspod/raw/master/LetsEncrypt-auto-dnspod.sh | bash"

read -p "Will dry-run for test?(default No): " dr
if [ "$dr" == "N" ] || [ "$dr" == "No" ] || [ "$dr" == "n" ] || [ "$dr" == "no" ]; then
    dr=""
fi
read -p "Please input your email: " useremail

echo "Please input your domains one by one(a.com,*.a.com ,I will not check it right or not):"
n=1
read -p "Input domain $n: " domains[$n]
while [ -n "${domains[$n]}" ]
do
    ((n=${n}+1))
    read -p "Input domain $n: " domains[$n]
done
#echo ${domains[@]}
for v in ${domains[@]}; do
   [ -n "${domainall}" ] && domainall=${domainall},${v} || domainall=${v}
done

echo "Get your dnspod_token from https://www.dnspod.cn/console/user/security"
while [ -z "${dnspod_token}" ]
do
    read -p "Please input your dnspod_token(Connect with commas','):" dnspod_token
done

[ ! -d "/etc/letsencrypt" ] && mkdir /etc/letsencrypt
[ ! -d "/etc/letsencrypt/script" ] && mkdir /etc/letsencrypt/script

basepath=$(cd `dirname $0`; pwd)
[ -s "$basepath/certbot-auth-dnspod.sh" ] && mv $basepath/certbot-auth-dnspod.sh /etc/letsencrypt/script/certbot-auth-dnspod.sh
[ -s "$basepath/certbot-cleanup-dnspod.sh" ] && mv $basepath/certbot-cleanup-dnspod.sh /etc/letsencrypt/script/certbot-cleanup-dnspod.sh

basepath=/etc/letsencrypt/script
cd $basepath
echo ${dnspod_token} >$basepath/dnspod_token

echo
echo
echo "###############################################################"
echo "your token is:     "${dnspod_token}
echo "your domain(s) is: "${domainall}
[ -n "${useremail}" ] && echo "your email is:     "${useremail} || echo "your email is:     NULL"
echo

cmdl="certbot certonly"
[ -n "${useremail}" ] && cmdl=${cmdl}" --email "${useremail} || cmdl=${cmdl}" --register-unsafely-without-email"
cmdl=${cmdl}" -d "${domainall}
cmdl=${cmdl}" --agree-tos --duplicate --manual --manual-public-ip-logging-ok --preferred-challenges dns-01 --manual-auth-hook $basepath/certbot-auth-dnspod.sh --manual-cleanup-hook $basepath/certbot-cleanup-dnspod.sh"
[ -n "${dr}" ] && cmdl=${cmdl}" --dry-run"
echo "your commandline:"
echo
echo ${cmdl}
echo

read -p "Press ENTER to start...or Press Ctrl+C to cancel" c

[ ! -s "$basepath/certbot-auth-dnspod.sh" ] && wget -N https://github.com/qkqpttgf/LetsEncrypt-auto-dnspod/raw/master/certbot-auth-dnspod.sh
[ ! -s "$basepath/certbot-cleanup-dnspod.sh" ] && wget -N https://github.com/qkqpttgf/LetsEncrypt-auto-dnspod/raw/master/certbot-cleanup-dnspod.sh
chmod +x certbot-auth-dnspod.sh
chmod +x certbot-cleanup-dnspod.sh

yum install wget python2-certbot-apache -y

${cmdl}

echo
[ "${domains[1]:0:2}" == "*." ] && firstdomain=${domains[1]:2:${#domains[1]}} || firstdomain=${domains[1]}
cat /etc/letsencrypt/renewal/${firstdomain}.conf
