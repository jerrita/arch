sudo pacman -S fcitx5-im #��������
sudo pacman -S fcitx5-chinese-addons #�ٷ�������������
sudo pacman -S fcitx5-anthy #������������
sudo pacman -S fcitx5-pinyin-moegirl #����ٿƴʿ�
sudo pacman -S fcitx5-material-color #����


sudo cat>/etc/environment<<EOF
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
SDL_IM_MODULE=fcitx
EOF