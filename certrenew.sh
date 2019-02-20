#!bash
#Auth: ysun

#main domain: the folder name in /etc/letsencrypt/live/
mdomain=某某.com
#zip path to web
certzipfile=/var/www/html/cer.zip

#renew log file name
d1="/root/renewlog/"
tname=`date +${d1}%Y%m%d-%H%M%S.log`
date >${tname}

#rm logfile > 3 month
cd $d1
for a in $(ls)
do
    f=${a%-*}
    n=`date +%Y%m%d`
    #echo $f,$n
    s=$((n-f));
    [ $s -gt 300 ] && rm -f $a >>${tname}
done

#run renew everyday, certbot will check, if less 30 days then do renew
/usr/bin/certbot renew >>${tname}

#get the date of pem
cd /etc/letsencrypt/live/$mdomain
fd=`ls --full-time cert.pem | awk '{print $6}'`
nd=`date +'%Y-%m-%d'`

#check if the pem renewed today
if [ "$nd" == "$fd" ]; then
    #make a pfx for IIS (password:1234)
    #openssl pkcs12 -export -out a.pfx -inkey privkey.pem -in cert.pem -passout pass:1234

    #delete old zipfile
    rm -f $certzipfile
    #create new zipfile
    cd /etc/letsencrypt/live
    /usr/bin/zip -r $certzipfile $mdomain

    #restart the http/https
    /bin/systemctl restart httpd
fi
