#!bash
#Auth: ysun

#renew log file name
d1="/root/renewlog/"
tname=`date +${d1}%Y%m%d-%H%M%S.log`
date >${tname}
#run renew everyday, certbot will check, if less 30 days then do renew
/usr/bin/certbot renew >>${tname}

#make a pfx for IIS,(password:1234)
#cd /etc/letsencrypt/live/baidu.com
#openssl pkcs12 -export -out a.pfx -inkey privkey.pem -in cert.pem -passout pass:1234

#delete old zipfile
rm -f /var/www/html/cer.zip
#create new zipfile
cd /etc/letsencrypt/live
/usr/bin/zip -r /var/www/html/cer.zip baidu.com

#restart the http/https
/bin/systemctl restart httpd
