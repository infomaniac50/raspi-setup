
MODULE_FILE='/etc/modules-load.d/ds1307.conf'
BOOT_SCRIPT='/usr/local/bin/rtcenable.sh'

if [[ ! -f $MODULE_FILE ]]; then
  echo '# Load kernel module for RTC DS1307 (also works with DS3231 in ChronoDot' >> $MODULE_FILE
  echo 'rtc_ds1307' >> $MODULE_FILE
fi

if [[ ! -f $BOOT_SCRIPT ]]; then
  echo '#!/usr/bin/env bash' >> $BOOT_SCRIPT
  echo 'echo ds1307 0x68 > /sys/class/i2c-adapter/i2c-0/new_device' >> $BOOT_SCRIPT
  echo 'hwclock -s' >> $BOOT_SCRIPT
fi

chmod +x $BOOT_SCRIPT
(
cat <<'EOF'
[Unit]
Description=Script to load DS1307 RTC i2c device during boot

[Service]
ExecStart=/usr/local/bin/rtcenable.sh

[Install]
WantedBy=multi-user.target
EOF
) > /etc/systemd/system/ds1307.service

systemctl enable ds1307.service
