#!/bin/bash

check() {
    # Only include the module if another module requires it
    return 255
}

depends() {
    echo "base debug qemu watchdog"
}

installkernel() {
    hostonly='' instmods \
        ata_piix \
        ext4 \
        i6300esb \
        ide-gd_mod \
        piix \
        sd_mod \
        virtio_pci \
        virtio_scsi
}
