# Dylan's NixOS Config

## Features
 - Impermanence using btrfs subvolumes
 - Virtual Machine management using [nixvirt](https://github.com/AshleyYakeley/NixVirt)
   - It is currently set up to look for VM storage named `win10.qcow2`, a Windows 10 iso (named `Win10_22H2_English_x64v1.iso`), and a [VirtIO disk](https://docs.fedoraproject.org/en-US/quick-docs/creating-windows-virtual-machines-using-virtio-drivers/) (named `virtio-win-0.1.266.iso`) in `/var/lib/libvirt/images`.
   - Connects two PCI devices (RTX 3060 & 3060 audio device)
 - Secret management using [sops-nix](https://github.com/Mic92/sops-nix)
 - Neovim configuration using [Nixvim](https://github.com/nix-community/nixvim)
