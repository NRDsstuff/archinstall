#!/bin/sh
localectl set-keymap pl2
setfont ter-d14n
if [ -d "/mnt" ]; then

pacstrap -K /mnt base linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab

# initial setup
arch-chroot /mnt <<EOF
    ln -sf /usr/share/zoneinfo/Poland /etc/localtime
    hwclock --systohc
    rm /etc/locale.gen
    echo "LANG=en_US.UTF-8
LC_ADDRESS=pl_PL.UTF-8
LC_IDENTIFICATION=pl_PL.UTF-8
LC_MEASUREMENT=pl_PL.UTF-8
LC_MONETARY=pl_PL.UTF-8
LC_NAME=pl_PL.UTF-8
LC_NUMERIC=pl_PL.UTF-8
LC_PAPER=pl_PL.UTF-8
LC_TELEPHONE=pl_PL.UTF-8
LC_TIME=pl_PL.UTF-8" > /etc/locale.conf
    echo "KEYMAP=pl2" > /etc/vconsole.conf
    echo "nrdeproseros" > /etc/hostname
    mkinitpcio -P
    yes | pacman -Syu
EOF

# bootloader
if [ -d /sys/firmware/efi ]; then

echo "running in efi mode"
arch-chroot /mnt <<EOF
    yes | pacman -S refind
    refind-install
EOF

else
    echo "running in non-efi mode, install the bootloader manually"
fi

# random packages
arch-chroot /mnt <<EOF
    yes | pacman -S flatpak syncthing 
EOF

# desktop
arch-chroot /mnt <<EOF
    yes | pacman -S gnome-logs gnome-menus gnome-session gnome-settings-daemon firefox gnome-shell gnome-software gnome-system-monitor gnome-text-editor evince gdm gnome-calculator gnome-calendar gnome-characters gnome-clocks gnome-control-center gnome-disk-utility gnome-font-viewer gnome-keyring gnome-weather grilo-plugins gvfs gvfs-dnssd gvfs-goa gvfs-google gvfs-gphoto2 gvfs-mtp gvfs-nfs gvfs-onedrive gvfs-smb gvfs-wsdd loupe nautilus snapshot sushi tecla totem xdg-desktop-portal-gnome tracker3-miners xdg-user-dirs-gtk gnome-tweaks noto-fonts-emoji pipewire-jack 
    gsettings set org.gnome.desktop.wm.preferences resize-with-right-button true
    systemctl enable gdm.service
EOF

else
    echo "mount the system partition then rerun the script"
    echo "this part has to be done manually because i said so"
fi