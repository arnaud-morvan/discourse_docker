#!/bin/sh

cd /var/www/discourse
rails c
SiteSetting.enable_sso = $ENABLE_SSO
SiteSetting.sso_url = $SSO_URL
SiteSetting.logout_redirect = $LOGOUT_REDIRECT 
SiteSetting.sso_secret = $SSO_SECRET
SiteSetting.force_https = $FORCE_HTTPS
exit
