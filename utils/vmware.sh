function configline() {
  local OLD_LINE_PATTERN=$1; shift
  local NEW_LINE=$1; shift
  local FILE=$1
  local NEW=$(echo "${NEW_LINE}" | sed 's/\//\\\//g')
  touch "${FILE}"
  sed -i '/'"${OLD_LINE_PATTERN}"'/{s/.*/'"${NEW}"'/;h};${x;/./{x;q100};x}' "${FILE}"
  if [[ $? -ne 100 ]] && [[ ${NEW_LINE} != '' ]]
    then
        echo "${NEW_LINE}" >> "${FILE}"
    fi
}

FUNC=$(declare -f configline)

sudo xrandr --newmode "1920x1080" 173.00 1920 2048 2248 2576 1080 1083 1088 1120 -hsync +vsync
sudo xrandr --addmode Virtual-1 "1920x1080"
sudo bash -c "$FUNC; configline '.*display-setup-script=' 'display-setup-script=xrandr --output Virtual-1 --mode 1920x1080' /etc/lightdm/lightdm.conf"
