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






















# temp
```bash
sudo pacman -S -needed git base-devel

cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay && makepkg -si
cd ~ && rm -rf /tmp/yay

sudo nvim /etc/pacman.conf
# enable multilib

sudo mesa lib32-mesa 
vulkan-intel lib32-vulkan-intel \
intel-media-driver \
libva-intel-driver

sudo pacman -S vulkan-tools
vulkaninfo --summary
vkcube # check vulkan

sudo pacman -S plasma plasma-desktop sddm \
dolphin konsole kate \
plasma-pa plasma-nm \
pipewire pipewire-pulse pipewire-alsa \
wireplumber \
xdg-user-dirs xdg-desktop-portal \
xdg-desktop-portal-kde \
ttf-liberation noto-fonts

systemctl enable sddm
systemctl --user enable pipewire pipewire-pulse wireplumber
xdg-user-dirs-update
sudo reboot
```

```bash
sudo pacman -S steam \
gamemode lib32-gamemode \
mangohub lib32-mangohub \
gamescope \
lib32-alsa-plugins lib32-libpulse \
lib32-openal lib32-sdl2 \
lib32-gst-plugins-base \
lib32-gst-plugins-good
```

```bash
sudo pacman -S lutris \
wine wine-gecko wine-mono \
winetricks \
lib32-gnutls lib32-libldab \
lib32-libgpg-error lib32-sqlite \
lib32-sdl2 lib32-sdl2_image
yay -S protonup-qt
yay -S dxvk-bin
yay -S vkd3d-proton-bin
echo "$(whoami) hard nofile 524288" | sudo tee -a /etc/security/limits.conf
echo "$(whoami) soft nofile 524288" | sudo tee -a /etc/security/limits.conf
ulimit -Hn
```
