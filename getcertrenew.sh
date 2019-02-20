#!bash
#Auth: ysun

#source zip: cbb.abc.com/path/cer.zip
mdomain=某某.com/path
certzipfile=cer.zip

#dir
dirpath=/root/
cd $dirpath

[ "${mdomain:0-1}" == "/" ] && webzip=$mdomain$certzipfile || webzip=$mdomain/$certzipfile
wget -N $webzip

if [ -s "$certzipfile" ]; then
    fd=`ls --full-time $certzipfile | awk '{print $6}'`
    nd=`date +'%Y-%m-%d'`

    if [ "$nd" == "$fd" ]; then
        [ "${dirpath:0-1}" == "/" ] && dirpath=$dirpath || dirpath=$dirpath/
        /usr/bin/unzip -o $dirpath$certzipfile -d $dirpath
        systemctl restart httpd
    fi
fi
