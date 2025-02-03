[Unit]
Description=subscription-manager
After=network.target
Wants=network.service

[Service]
EnvironmentFile=/etc/default/subscription-manager
Type=forking
PIDFile=/var/run/subscription-manager/subscription-manager.pid
#User=subscription-manager
#Group=subscription-manager
ExecStart=/usr/bin/subscription-manager $OPTIONS -p /var/run/subscription-manager/subscription-manager.pid
KillMode=process
Restart=no

[Install]
WantedBy=multi-user.target
