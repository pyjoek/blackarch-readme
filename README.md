# Installing and managing blackarch toold
## Make sure you have installed any arch linux (eg; manjaro)
## Install black arch ontop of manjaro
### Update manjaro
    sudo pacman -Syy
    sudo pacman -Syu
### Install the right keys 
    sudo pacman-key --init
    sudo pacman-key --populate archlinux blackarch
### sync the mirror keys
    sudo pacman -Sy
### Install blackarch tools
    sudo pacman -S --needed blackarch
### Refresh the mirros incase you face slowness
    sudo pacman-mirrors --fasttrack
    sudo pacman -Sy
### Then reinstall black arch again
