#!/usr/bin/env bash

wget -O /tmp/netdata-kickstart.sh https://get.netdata.cloud/kickstart.sh && sh /tmp/netdata-kickstart.sh --stable-channel --disable-telemetry
sudo wget -O /etc/netdata/netdata.conf http://localhost:19999/netdata.conf

# edit: /etc/netdata/health_alarm_notify.conf
# SEND_TELEGRAM="YES"
# TELEGRAM_BOT_TOKEN="your_bot_token"
# DEFAULT_RECIPIENT_TELEGRAM="your_chat_id"

# test: /usr/libexec/netdata/plugins.d/alarm-notify.sh test
