# Dylan's NixOS Config

## Features
 - Disk and mount management with [disko](https://github.com/nix-community/disko)
 - Impermanence with BTRFS subvolumes
 - Virtual Machine management with [nixvirt](https://github.com/AshleyYakeley/NixVirt)
   - Looks for 3 images in `/var/lib/libvirt/images`:
     - `win11.qcow2`: VM Storage that contains the Windows 11 operating system
     - `Win11_25H2_English_x64.iso`: Windows 11 installation image
     - `virtio-win-0.1.285.iso`: [VirtIO disk](https://docs.fedoraproject.org/en-US/quick-docs/creating-windows-virtual-machines-using-virtio-drivers/)
   - Connects two PCI devices (10de:2504, 10de:228e)
 - Secret management using [sops-nix](https://github.com/Mic92/sops-nix)

## Installation
 1. Run the disko config
`sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount nixos/disko-config.nix`
  - ❗ IMPORTANT: Change the value of `disko.devices.disk.main.device` before formatting to the correct disk.
 2. Copy everything to `/mnt/etc/nixos`
 3. Copy `ssh_host_ed25519_sops` and `ssh_host_ed25519_sops.pub` to `/mnt/etc/ssh`
 4. Install NixOS
`sudo nixos-install --flake /mnt/etc/nixos#bleistein`
 5. Copy `/mnt/etc/ssh` and `/mnt/etc/nixos` to `/mnt/persist/etc`
