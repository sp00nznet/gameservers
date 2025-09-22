#[Install steamcmd]
if [ ! -f /opt/steamcmd/steamcmd.sh ]; then mkdir /opt/steamcmd/ && cd /opt/steamcmd/ &&curl -sqL "ht
tps://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -; fi

#[Run steamcmd and update the game server]

/opt/steamcmd/steamcmd.sh +force_install_dir /opt/tf2server/ +login anonymous +app_update 232250 validate +quit

#[Create our systemd service file]

echo "[Unit]
Description=Team Fortress 2 Server
After=network.target

[Service]
WorkingDirectory=/opt/tf2server/
Type=forking
Restart=always
ExecStart=/usr/bin/screen -d -m -S "tf2server" -h 1024 /opt/tf2server/srcds_run -console -game tf +sv_pure 1 +randommap +maxplayers 24 +sv_setsteamaccount [STEAMTOKEN] 

[Install]
WantedBy=multi-user.target" | dd of=/etc/systemd/system/tf2server.service

#[Enable our service on boot and start up game server]

systemctl daemon-reload
systemctl enable /etc/systemd/system/tf2server.service
systemctl start tf2server
