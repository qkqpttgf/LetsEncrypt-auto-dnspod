#!/bin/bash

#
# Author: ysun
#
USER_AGENT="ysun LetsEncrypt Renew/0.0.1 (qkqpttgf@gmail.com)";

# https://www.dnspod.cn/console/user/security
#API_TOKEN=""
basepath=$(cd `dirname $0`; pwd)

DOMAIN=$(expr match "$CERTBOT_DOMAIN" '.*\.\(.*\..*\)')
[ -z "$DOMAIN" ] && DOMAIN="$CERTBOT_DOMAIN"

if [ -z "$API_TOKEN" ]; then
    [ -f $basepath/dnspod_token_$DOMAIN ] && API_TOKEN=$(cat $basepath/dnspod_token_$DOMAIN)
fi

if [ -z "$API_TOKEN" ]; then
    [ -f $basepath/dnspod_token ] && API_TOKEN=$(cat $basepath/dnspod_token)
fi
if [ -z "$API_TOKEN" ]; then
    [ -f $basepath/token ] && API_TOKEN=$(cat $basepath/token)
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

RECORDS=$(curl -s -X POST "https://dnsapi.cn/Record.List" \
    -H "User-Agent: $USER_AGENT" \
    -d "$PARAMS&domain=$CERTBOT_DOMAIN&keyword=_acme-challenge" \
| python -c "import sys,json;ret=json.load(sys.stdin);print(ret.get('records',[{}])[0].get('id',ret.get('status',{}).get('message','error')))")

echo "\
RECORDS:        $RECORDS"

sleep 3

    RECORD_ID=$(curl -s -X POST "https://dnsapi.cn/Record.Create" \
    -H "User-Agent: $USER_AGENT" \
        -d "$PARAMS&domain=$CERTBOT_DOMAIN&sub_domain=_acme-challenge&record_type=TXT&value=$CERTBOT_VALIDATION&record_line=默认" \
    | python -c "import sys,json;ret=json.load(sys.stdin);print(ret.get('record',{}).get('id',ret.get('status',{}).get('message','error')))")

echo "\
RECORD_ID:      $RECORD_ID"

# Sleep to make sure the change has time to propagate over to DNS
sleep 60
