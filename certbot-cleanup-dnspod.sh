#!/bin/bash

#
# Author: ysun
#
USER_AGENT="ysun LetsEncrypt Renew/0.0.1 (qkqpttgf@gmail.com)";

# https://www.dnspod.cn/console/user/security
API_TOKEN=""

DOMAIN=$(expr match "$CERTBOT_DOMAIN" '.*\.\(.*\..*\)')
[ -z "$DOMAIN" ] && DOMAIN="$CERTBOT_DOMAIN"
basepath=$(cd `dirname $0`; pwd)
if [ -z "$API_TOKEN" ]; then
    [ -f $basepath/dnspod_token_$DOMAIN ] && API_TOKEN=$(cat $basepath/dnspod_token_$DOMAIN)
fi

if [ -z "$API_TOKEN" ]; then
    [ -f $basepath/dnspod_token ] && API_TOKEN=$(cat $basepath/dnspod_token)
fi

if [ -z "$API_TOKEN" ]; then
    API_TOKEN="$DNSPOD_TOKEN"
fi

PARAMS="login_token=$API_TOKEN&format=json"

echo "\
CERTBOT_DOMAIN: $CERTBOT_DOMAIN
DOMAIN:         $DOMAIN
VALIDATION:     $CERTBOT_VALIDATION"
#echo "PARAMS:         $PARAMS"
while [ "$RECORDS" != "No records" ]
do
RECORDS=$(curl -s -X POST "https://dnsapi.cn/Record.List" \
    -H "User-Agent: $USER_AGENT" \
    -d "$PARAMS&domain=$CERTBOT_DOMAIN&keyword=_acme-challenge" \
| python -c "import sys,json;ret=json.load(sys.stdin);print(ret.get('records',[{}])[0].get('id',ret.get('status',{}).get('message','error')))")

echo "\
e_RECORDS:      $RECORDS"

sleep 2

if [ "$RECORDS" != "No records" ]; then
    RECORD_ID="$RECORDS"
    RECORD_ID=$(curl -s -X POST "https://dnsapi.cn/Record.Remove" \
    -H "User-Agent: $USER_AGENT" \
        -d "$PARAMS&domain=$CERTBOT_DOMAIN&sub_domain=_acme-challenge&record_id=$RECORD_ID" \
    | python -c "import sys,json;ret=json.load(sys.stdin);print(ret.get('record',{}).get('id',ret.get('status',{}).get('message','error')))")
fi

echo "\
RECORD_ID:      $RECORD_ID"

sleep 1
done
