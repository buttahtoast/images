# CIDATA Images

We provide in this repo multiple KVM Images to stage via Cloud-init (cloud-config) via CIDATA or NoCloud.
You will find all available images here https://github.com/buttahtoast/images/releases

## Notes Flatcar
There is a serivce called `install.service` which deploys cloud-init from a cidata device with `coreos-cloudinit` binaries.
Currently we deploy a qemu-qa binary (ubuntu complied) via cloud-init. Open for
other solutions.

## Builds
Our builds are public visible under https://drone.buttahtoast.ch/buttahtoast/images/ we use a optimised runner for kvm acceleration.

