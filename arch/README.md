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
    - **fdisk [disk]** to partition [disk]
    - commands:
    ```bash
      d to delete
      n for create a new partition
      w to write
      p for printing all the partition in [disk]
    ```
  - layout:
  ```bash
    efi: /: FAT32: 100M
    boot: /boot: EXT4: 512M
    lvm
  ```
-----------------------------------------------------------------------
- Partitioning LVM
```bash
cryptsetup luksFormat [lvm]
cryptsetup open --type luks [encrypted] cryptlvm_0
# can repeate for as many partitions and use for the lvm

# configuring lvm
pvcreate /dev/mapper/cryptlvm_0 ...
vgcreate volgroup0 dev/mapper/cryptlvm_0 ...
# vgextend to add partition to a volgroup
# see the volume group via vgdisplay or vgscan

#lvcreate -L [size] [volgroup] -n [partition name]
lvcreate -L 60G volgroup0 -n lv_root
lvcreate -L 36G volgroup0 -n lv_swap
lvcreate -l 100%FREE volgroup0 -n lv_home
lvreduce --size -256M volgroup0/lv_home
# check via lvdisplay or lvscan

modprobe md_mod # can omit

vgscan
vgactivate -ay
```
-----------------------------------------------------------------------
- Format:
```bash
mkfs.fat -F32 [efi]
mkfs.ext4 [boot]
mkfs.ext4 /dev/volgroup0/lv_root
mkfs.ext4 /dev/volgroup0/lv_home
mkswap /dev/volgroup0/lv_swap
```
-----------------------------------------------------------------------
- Mounting
```bash
mount /dev/volgroup0/lv_root /mnt
mount --mkdir [efi] /mnt/efi
mount --mkdir [boot] /mnt/boot
mount --mkdir /dev/volgroup0/lv_home /mnt/home
swapon /dev/volgroup0/lv_swap
```
-----------------------------------------------------------------------
- Installing arch
```bash
pacstrap -K /mnt base linux linux-firmware \
base-devel nano vim neovim sudo intel-ucode lvm2
genfstab -U /mnt >> /mnt/etc/fstab 
# verify
cat /mnt/etc/fstab

# change into the root user
arch-chroot /mnt /bin/bash
ln -sf /usr/share/zoneinfo/Asia/Saigon /etc/localtime
hwclock --systohc 

nvim /etc/locale.gen
# uncomment the desired locale
locale-gen
echo LANG=en_us.UTF-8 > /etc/locale.conf

# change the host name
echo archlinux >> /etc/hostname

# set root password
passwd

# add user
useradd -g [prim_gr] -G wheel --shell [username]
# other supplementary group
# wheel for sudo privileges
# video for capturing video
# audio for capturing audio
# lp for printing task
# cdrom for mounting access
# d8alout for porting
# docker for manage Docker containers without sudo
# wireshark for capturing network packets
# systemd-journal for easy system logs reading

# setup user's password
passwd [username]

# give wheel group's users sudo privileges
EDITOR=nvim visudo
# and uncomment %wheel ALL=(ALL:ALL) ALL

nvim /etc/mkinitcpio.conf
#HOOKS=(base udev autodetect modconf block encrypt lvm2 filesystems keyboard fsck )
# for multi-encrypted partitions:
# udev -> systemd, encrypt -> sd-encrypt
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
# GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 cryptdevice=UUID=[UUID]:cryptlvm root=/dev/volgroup0/lv_root quiet"
# udev, encrypt -> systemd, sd-encrypt is more complex
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
pacman -S plasma plasma-wayland-session
pacman -S dolphin kate ark kcalc kdeconnect konsole \
print-manager elisa dragon ffmpegthumbs gwenview  \
skanlite spectacle okular packagekit-qt5 ksystemlog \
partitionmanager kdialog
systemctl enable sddm
```
  - Hyprland
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
