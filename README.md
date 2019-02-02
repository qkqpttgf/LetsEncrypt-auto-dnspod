# LetsEncrypt-auto-dnspod
auto get&amp;renew cert

CentOS7用yum install python2-certbot-apache安装。

certbot certonly --email abc@163.com -d a.com -d *.a.com -d b.cn,*.b.cn --duplicate --manual --preferred-challenges dns-01 --manual-auth-hook /root/certbot-auth-dnspod.sh --manual-cleanup-hook /root/certbot-clean-dnspod.sh

certonly是指只生成SSL的公私钥文件，不自动合并到网站的设置中，这样我们拿到文件后可以自己决定用在哪个网站上。
--email后接邮箱，快到期了会有邮件通知。-d后接需要的域名，注意a.com跟*.a.com都要写上，不然www.a.com可以访问，a.com就不可信了。可以写多个-d，也可以在一个-d后面用英文逗号分隔。
--manual如果没有这个，后续会让选择apache等网站验证方式，用dns验证的要加上。
--preferred-challenges dns-01指定所有的域名用dns方式来验证归属权
--manual-auth-hook /root/certbot-auth-dnspod.sh指定申请时使用的自动脚本，名称随便取，但要注意提前给脚本运行权限：chmod +x 某某某.sh
--manual-cleanup-hook /root/certbot-cleanup-dnspod.sh指定申请后的清理脚本，也需要运行权限
