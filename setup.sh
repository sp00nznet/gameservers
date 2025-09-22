HEIGHT=15
WIDTH=40
CHOICE_HEIGHT=4
BACKTITLE="Silverware Game Servers"
TITLE="Server Options"
MENU="Choose one of the following options:"

OPTIONS=(1 "Killing Floor"
         2 "Killing Floor 2"
         3 "Team Fortress 2")

CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
        1)
            ./killingfloor/kf-server-setup.sh
            ;;
        2)
            ./killingfloor2/kf2-server-setup.sh
            ;;
        3)
            ./teamfortress2/tf2-server-setup.sh
            ;;
esac

