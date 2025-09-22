#[Install steamcmd]

if [ ! -f /opt/steamcmd/steamcmd.sh ]; then mkdir /opt/steamcmd/ && cd /opt/steamcmd/ &&curl -sqL "ht
tps://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -; fi

#[Run Steamcmd and update the game server]

/opt/steamcmd/steamcmd.sh +force_install_dir /opt/kf2server/ +login anonymous +app_update 232130 validate +quit

#[Create our systemd service file]

echo "
[Unit]
Description=Killing Floor 2 Server
After=network.target

[Service]
WorkingDirectory=/opt/kf2server/
Type=forking
Restart=always
ExecStart=/usr/bin/screen -d -m -S "kf2server" -h 1024 /opt/kf2server/Binaries/Win64/KFGameSteamServer.bin.x86_64 kf-bioticslab

[Install]
WantedBy=multi-user.target" | dd of=/etc/systemd/system/kf2server.service

#[Enable our service on boot and start up game server]

systemctl daemon-reload
systemctl enable /etc/systemd/system/kf2server.service
systemctl start kf2server
