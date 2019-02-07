#!bash
#Auth: ysun

wget -N ysun.cn/cer.zip
/usr/bin/unzip -o /root/cer.zip -d /root/
systemctl restart httpd
