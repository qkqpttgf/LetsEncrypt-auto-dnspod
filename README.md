# LetsEncrypt-auto-dnspod
auto get&amp;renew cert

CentOS7用yum install python2-certbot-apache安装。

certbot certonly --email abc@163.com -d a.com -d *.a.com -d b.cn,*.b.cn --duplicate --manual --preferred-challenges dns-01 --manual-auth-hook /root/certbot-auth-dnspod.sh --manual-cleanup-hook /root/certbot-clean-dnspod.sh
--preferred-challenges dns-01指定所有的域名用dns方式来验证归属权
--manual-auth-hook /root/certbot-auth-dnspod.sh指定申请时使用的自动脚本，名称随便取，但要注意提前给脚本运行权限：chmod +x 某某某.sh
--manual-cleanup-hook /root/certbot-cleanup-dnspod.sh指定申请后的清理脚本，也需要运行权限
