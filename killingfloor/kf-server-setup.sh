#[Install steamcmd]

if [ ! -f /opt/steamcmd/steamcmd.sh ]; then mkdir /opt/steamcmd/ && cd /opt/steamcmd/ &&curl -sqL "ht
tps://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -; fi

#[Run steamcmd and update the game server]

/opt/steamcmd/steamcmd.sh +force_install_dir /opt/kf1server/ +login anonymous +app_update 215360 validate +quit

#[Create our systemd service file]

echo "[Unit]
Description=Killing Floor 1 Server
After=network.target

[Service]
WorkingDirectory=/opt/kfserver/System/
Type=forking
Restart=always
ExecStart=/usr/bin/screen -d -m -S "kf1server" -h 1024 /opt/kfserver/System/ucc-bin server KF-westlondon.rom?Mutator=MutLoader.MutLoader?game=KFmod.KFGameType?VACSecured=true?MaxPlayers=6 logs=/var/log/kfserver.log -nohomedir

[Install]
WantedBy=multi-user.target" | dd of=/etc/systemd/system/kf1server.service

#[Enable our service on boot and start up game server]

systemctl daemon-reload
systemctl enable /etc/systemd/system/kf1server.service
systemctl start kf1server
