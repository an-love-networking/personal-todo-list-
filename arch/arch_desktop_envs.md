- Install a desktop env


    ```bash
    sudo pacman -S --noconfirm --needed \
         plasma plasma-desktop sddm \
         dolphin konsole kate \
         plasma-pa plasma-nm \
         pipewire pipewire-pulse pipewire-alsa \
         wireplumber \
         xdg-user-dirs xdg-desktop-portal \
         xdg-desktop-portal-kde \
         ttf-liberation noto-fonts   
    sudo systemctl enable sddm
    systemctl --user enable pipewire pipewire-pulse wireplumber
    xdg-user-dirs-update
    ```

  - Hyprland ( will figure out later )
    ```bash
    sudo pacman -S hyprland
    ```
