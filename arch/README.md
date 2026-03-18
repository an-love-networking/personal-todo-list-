# Linux learning curve (atleast for me)
## THINGS I NEED TO DO TO INSTALL ARCH **MANUALLY** for some reason
1. Image booting
- Download .iso image
- Load the image into a bootable USB
  - On linux: **dd bs=4M if=[iso file] of=[usb] status=progress && sync**
    - [usb] can be obtained via **lsblk**
  - Otherwise: use etcher.balena

2. Manual installation
- set keyboard layout: 
  - listings layouts: **localectl list-keymaps**
  - **loadkeys [keymaps]**

- connect to internet: iwctl
- set font size (for readability): **setfont -d** to double fontsize
- synchronize clock: **timedatectl net-ntp true**

- partitioning:
  - modern: **cfdisk**
  - for who love the text-ish way of partitioning: **fdish -l** for listing disks
    - **gdisk [disk]** to partition [disk]
    - commands:
    ```bash
      d to delete
      n for create a new partition
      w to write
      p for printing all the partition in [disk]
      t for changing partition type
    ```
  - layout:
  ```bash
    efi: /efi: FAT32: 100M
    lvm:
      root: /mnt
      home: /mnt/home
      swap
      [snapshot]
  ```
-----------------------------------------------------------------------
- Partitioning LVM
```bash
cryptsetup luksFormat /dev/[disk]
cryptsetup open --type luks /dev/[disk] cryptlvm_i
# can repeate for as many partitions and use for the lvm

# configuring lvm
pvcreate /dev/mapper/cryptlvm_i ...
vgcreate volgroup0 dev/mapper/cryptlvm_i ...
# vgextend to add partition to a volgroup
# see the volume group via vgdisplay or vgscan

#lvcreate -L [size] [volgroup] -n [partition name]
lvcreate -L 60G volgroup0 -n lv_root
lvcreate -L 36G volgroup0 -n lv_swap
lvcreate -l 100%FREE volgroup0 -n lv_home
lvreduce --size -256M volgroup0/lv_home
# check via lvdisplay or lvscan

# modprobe md_mod 

# vgscan
# vgactivate -ay
```
-----------------------------------------------------------------------
- Format:
```bash
mkfs.fat -F32 [efi]
mkfs.ext4 /dev/volgroup0/lv_root
mkfs.ext4 /dev/volgroup0/lv_home
mkswap /dev/volgroup0/lv_swap
```
-----------------------------------------------------------------------
- Mounting
```bash
mount /dev/volgroup0/lv_root /mnt
mount --mkdir [efi] /mnt/efi
mount --mkdir /dev/volgroup0/lv_home /mnt/home
swapon /dev/volgroup0/lv_swap
```
-----------------------------------------------------------------------
- Installing arch
```bash
pacstrap -K /mnt base linux linux-firmware \
base-devel neovim git intel-ucode
genfstab -U /mnt >> /mnt/etc/fstab 
# verify
cat /mnt/etc/fstab
```
-----------------------------------------------------------------------
- Change into root and configure
```bash
# change into the root user
arch-chroot /mnt /bin/bash
```
- Synchronize clock and setup locale
```bash
ln -sf /usr/share/zoneinfo/Asia/Saigon /etc/localtime
hwclock --systohc 

nvim /etc/locale.gen # uncomment the desired locale
locale-gen
nvim /etc/locale.conf # LANG=en_US.UTF-8

nvim /etc/vconsole.conf # KEYMAP=us
```
- Setup hostname
```bash
nvim /etc/hostname
# archlinux

nvim /etc/hosts
# 127.0.0.1 localhost
# ::1 localhost
# 127.0.1.1 archlinux
```
- Change the root password
```bash
passwd
```
- Add user and change password
```bash
useradd -g [prim_gr] -mG wheel [username]
# other supplementary group
# wheel for sudo privileges
# video for capturing video
# audio for capturing audio
# lp for printing task
# cdrom for mounting access
# dialout for porting
# docker for manage Docker containers without sudo
# wireshark for capturing network packets
# systemd-journal for easy system logs reading

passwd [username]
```
- Enable sudo for all wheel users
```bash
EDITOR=nvim visudo
# uncomment %wheel ALL=(ALL:ALL) ALL
```
- Add hooks
```bash
nvim /etc/mkinitcpio.conf
# HOOKS=(base udev autodetect modconf block encrypt lvm2 filesystems keyboard fsck )
# or    (systemd   autodetect modconf kms keyboard sd-vconsole block sd-encrypt lvm2 resume filesystems fsck)
mkinitcpio -P
# enable network manager
pacman -S networkmanager
systemctl enable NetworkManager
```
-----------------------------------------------------------------------
- Install bootloader
```bash
pacman -S grub os-prober efibootmgr

grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB

nvim /etc/default/grub
# uncomment GRUB_DISABLE_OS_PROBER=false
# GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 cryptdevice=UUID=[UUID]:cryptlvm root=/dev/mapper/vg0-lv_root resume=/dev/mapper/vg0-lv_swap quiet"
# or cryptdevice -> rd.luks.name=[uuid]=lvm
grub-mkconfig -o /boot/grub/grub.cfg
```
-----------------------------------------------------------------------
- Setting keyfile for multiple hard disks encrypted with LUKS
```bash
mkdir -p /etc/luks-keys

dd if=/dev/urandom of=/etc/luks-keys/secondary-disk.key bs=52 count=4

chmod 600 /etc/luks-keys/secondary-disk.key

cryptsetup luksAddKey /dev/[secondary disk] /etc/luks-keys/secondary-disk.key

nvim /etc/crypttab
# <name> <device> <password> <options>
# name UUID=[UUID] /etc/luks-keys/secondary-disk.key luks
# [name] is the name in /dev/mapper/

nvim /etc/fstab
# <filesystem> <mounting point> <type> <option> <dump> <pass>
# /dev/mapper/[name] /mnt/data/ ext4 defaults 0 2
```
-----------------------------------------------------------------------
- Install a desktop env
  - KDE Plasma
```bash
pacman -S plasma-desktop sddm konsole dolphin \
plasma-nm sscreenlocker plasma-pa systemsettings kde-gtk-config \
powerdevil qt6-wayland
systemctl enable sddm
```
  - Hyprland ( will figure out later )
```bash
sudo pacman -S hyprland
```
## POST INSTALLATION
- Audio
```bash
sudo pacman -S pipewire pipewire-audio pipewire-alsa pipewire-pulse
```
- Printer
```bash
sudo pacman -S cups
sudo systemctl enable cups.service
```
- Steam
```bash
nvim /etc/pacman.conf
# uncomment multilib
```
- Spellchecking
```bash
sudo pacman -S hunspell hunspell-en_us
```
- For developing
```bash
sudo pacman -S neovim clangd python git lazygit ripgrep \
npm nodejs 
```
- Exit
```bash
exit
umount -R /mnt
swapoff -a
reboot
```

- install AUR (arch unified repo)
```bash
pacman -S --needed git base-devel && git clone  https://aur.archlinux.org/yay.git \ 
&& cd yay && makepkg -si
```
- install gpu drivers
  - nvidia nvidia-utils nvidia-settings for Nvidia GPUs
  - mesa xf86-video-{intel, amdgpu} for Intel and AMD GPUs
- envycontrol for hybrid/integrated GPUs
  - envycontrol --query: displaying current mode
  - envycontrol --switch {integrated, hybrid, nvidia}: switching mode
- install unikey ( for i am vietnamese )\
```bash
sudo pacman -S fcitx5 fcitx5-gtk fcitx5-qt fcitx5-configtool fcitx5-unikey
echo export XMODIFIERS=@im=fcitx >> ~/.bash_profile
echo export GTK_IM_MODULE=fcitx >> ~/.bash_profile
echo export QT_IM_MODULE=fcitx >> ~/.bash_profile
```
- Install Fira Code Nerd font
```bash
yay -S nerd-fonts-fira-code
```
