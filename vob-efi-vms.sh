
for y in {01..10};do
NAME="ra02-01-vm${y}";
virt-install \
--name=${NAME} \
--cpu=host-model-only \
--print-xml \
--noautoconsole \
--memballoon model=virtio \
--virt-type kvm \
--arch x86_64 \
--boot loader=/usr/share/qemu-efi/QEMU_EFI.fd \
--boot network,hd \
--network=bridge:ra02-rtr-01,model=virtio \
--disk path=/srv/vms/${NAME}.qcow2,format=qcow2,size=5,device=disk,bus=virtio,cache=writeback \
--memory=2048 \
--vcpu=1 \
--sysinfo smbios \
--sysinfo system.manufacturer='Canonical' \
--sysinfo system.product="$(lsb_release -sc|awk '{print toupper($0)}')-UEFI-VM" \
--sysinfo system.version="$(lsb_release -sr)" \
--sysinfo system.serial="$(env LANG=C LC_ALL=C tr 2>/dev/null -dc "[:alnum:]" < /dev/urandom|fold -w12|head -n1)" \
--graphics vnc \
--video qxl > /srv/vms/${NAME}.xml
	virsh define /srv/vms/${NAME}.xml
done

for y in {01..10};do
NAME="ra02-02-vm${y}";
virt-install \
--name=${NAME} \
--cpu=host-model-only \
--print-xml \
--noautoconsole \
--memballoon model=virtio \
--virt-type kvm \
--arch x86_64 \
--boot loader=/usr/share/qemu-efi/QEMU_EFI.fd \
--boot network,hd \
--network=bridge:ra02-rtr-02,model=virtio \
--disk path=/srv/vms/${NAME}.qcow2,format=qcow2,size=5,device=disk,bus=virtio,cache=writeback \
--memory=2048 \
--vcpu=1 \
--sysinfo smbios \
--sysinfo system.manufacturer='Canonical' \
--sysinfo system.product="$(lsb_release -sc|awk '{print toupper($0)}')-UEFI-VM" \
--sysinfo system.version="$(lsb_release -sr)" \
--sysinfo system.serial="$(env LANG=C LC_ALL=C tr 2>/dev/null -dc "[:alnum:]" < /dev/urandom|fold -w12|head -n1)" \
--graphics vnc \
--video qxl > /srv/vms/${NAME}.xml
	virsh define /srv/vms/${NAME}.xml
done


|xargs -rn1 -P0 bash -c \
'export $0;virt-install \
--name=${NAME} \
--cpu=host-model-only \
--print-xml \
--noautoconsole \
--memballoon model=virtio \
--virt-type kvm \
--arch x86_64 \
--boot loader=/usr/share/qemu-efi/QEMU_EFI.fd \
--boot network,hd \
--network=bridge:${NAME%-*}-rs01,model=virtio \
--disk path=/srv/vms/${NAME}.qcow2,format=qcow2,size=5,device=disk,bus=virtio,cache=writeback \
--memory=2048 \
--vcpu=1 \
--sysinfo smbios \
--sysinfo system.manufacturer=Canonical \
--sysinfo system.product="$(lsb_release -sc|awk '"'"'{print toupper($0)}'"'"')-UEFI-VM" \
--sysinfo system.version="$(lsb_release -sr)" \
--sysinfo system.serial="$(env LANG=C LC_ALL=C tr 2>/dev/null -dc "[:alnum:]" < /dev/urandom|fold -w12|head -n1)" \
--graphics vnc \
--video qxl > /srv/vms/${NAME}.xml
	virsh define /srv/vms/${NAME}.xml'



