# THINGS I NEED TO DO TO INSTALL ARCH **MANUALLY** for some reason
1. Image booting
- Download .iso image at ```https://archlinux.org/download/```
- Etch image on USB
- Boot in USB

2. Manual installation
- Table of contents:
  1 Partitioning
  2 Install packages for root via ```pacstrap -K```
  3 Setup root password and add user
  4 Install more packages
- [Optional] Set keyboard layout
  - listings layouts: ```localectl list-keymaps```
  - ```loadkeys [keymaps]```

- connect to internet ```iwctl```
-----------------------------------------------------------------------
- Partitioning:
  - Listing partitions/disks ```lsblk```
  - Partitioning ```cfdisk or gdisk```
  - Layout
    ```
    root:/mnt
    |- efi
    |- home
    |- swap
    ```

- Setup LVM
  - Encryption
    ```bash
    cryptsetup luksFormat /dev/[disk]
    cryptsetup open /dev/[disk] lvm
    # can repeate for as many partitions and use for the lvm
    ```

  - Create logic volumes
    ```bash
    pvcreate /dev/mapper/cryptlvm_i ...
    vgcreate volgroup0 dev/mapper/cryptlvm_i ...
    # vgextend to add partition to a volgroup
    # see the volume group via vgdisplay or vgscan
    
    lvcreate -L 60G volgroup0 -n lv_root
    lvcreate -L 36G volgroup0 -n lv_swap
    lvcreate -l 100%FREE volgroup0 -n lv_home
    # check via lvdisplay or lvscan
    ```

- Format:
  ```bash
  mkfs.fat -F32 [efi]
  mkfs.ext4 /dev/volgroup0/lv_root
  mkfs.ext4 /dev/volgroup0/lv_home
  mkswap /dev/volgroup0/lv_swap
  ```

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
  pacstrap -K /mnt base linux linux-firmware linux-headers \
  base-devel networkmanager intel-ucode \ # or amd-ucode
  git neovim
  genfstab -U /mnt >> /mnt/etc/fstab 
  # verify
  cat /mnt/etc/fstab
  ```
-----------------------------------------------------------------------
- Change into root and configure
  ```bash
  arch-chroot /mnt 
  ```

- Just follow this dont ask anything
  ```bash
  ln -sf /usr/share/zoneinfo/Asia/Saigon /etc/localtime
  hwclock --systohc 
  
  nvim /etc/locale.gen # uncomment the desired locale
  locale-gen
  echo LANG=en_US.UTF-8 >> /etc/locale.conf
  echo KEYMAP=us >> /etc/vconsole.conf
  echo archlinux >> /etc/hostname
  echo 127.0.1.1 archlinux >> /etc/hosts
  passwd
  useradd -g [prim_gr] -mG wheel,audio,video,storage,input,games -s /bin/bash [username]
  passwd [username]
  EDITOR=nvim visudo
  # uncomment %wheel ALL=(ALL:ALL) ALL
  system enable NetworkManager
  ```

- Setup bootloader
 ```bash
bootctl install
bootctl status

cat > /boot/loader/loader.conf << EOF
default arch.conf
timeout 3
console-mode max
editor no
EOF
mkdir -p /boot/loader/entries

cat > /boot/loader/entries/arch.conf << EOF
title Arch Linux
linux /vmlinuz-linux
initrd intel-ucode.img
initrd initramfs-linux.img
options root=UUID=[root uuid] rw quiet splash
EOF

exit
umount -R mnt
swapoff -a
reboot
```

- Add hooks
```bash
nvim /etc/mkinitcpio.conf
# HOOKS=( ... )
# replace udev->systemd
# add sd-encrypt, lvm2, resume after block
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
- If have many encrypted drives, you should setup a keyfile that will be automatically loaded once the root drive is decrypted
```bash
mkdir -p /etc/luks-keys

dd bs=512 count=4 if=/dev/urandom of=/etc/luks-keys/secondary-disk.key

chmod 400 /etc/luks-keys/secondary-disk.key

cryptsetup luksAddKey /dev/[other encrypted disk] /etc/luks-keys/secondary-disk.key

nvim /etc/crypttab
# <name> <device> <password> <options>
# name UUID=[UUID] /etc/luks-keys/secondary-disk.key luks
# [name] is the name in /dev/mapper/

nvim /etc/fstab
# <filesystem> <mounting point> <type> <option> <dump> <pass>
# /dev/mapper/[name] /mnt/data/ ext4 defaults 0 2
```








