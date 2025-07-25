# Push changes into vm
scp -P 2222 -r SENG440 PROJECT root@localhost:/root/

# STARTING VM change virt section to change machine??
qemu-system-arm -m 1G -smp 1 -hda Fedora-Minimal-armhfp-29-1.2-sda.qcow2 -machine virt-2.11 -kernel vmlinuz-4.18.16-300.fc29.armv7hl -initrd initramfs-4.18.16-300.fc29.armv7hl.img -append "console=ttyAMA0 rw root=LABEL=_/ rootwait ipv6.disable=1" -netdev user,id=seng440,hostfwd=tcp::2222-:22 -device virtio-net-pci,netdev=seng440

login: root
password: seng440

# CLOSING VM
shutdown -P now

# TESTING
Ensure audio file is exported as mono .wav file with 8000Hz sample rate
play compressed file - ffplay -f mulaw -ar 8000 compressed_output.ulaw    
   