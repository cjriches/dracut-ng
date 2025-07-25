#!/bin/bash

# called by dracut
check() {
    if [[ ! ${hostonly-} ]]; then
        return 0
    fi
    [[ $DRACUT_KERNEL_MODALIASES && -f $DRACUT_KERNEL_MODALIASES ]] \
        && grep -q libnvdimm "$DRACUT_KERNEL_MODALIASES" && return 0
    return 255
}

# called by dracut
installkernel() {
    # Directories to search for NVDIMM "providers" (firmware drivers)
    # These modules call "nvdimm_bus_register()".
    #instmods() will take care of hostonly
    dracut_instmods -o -s nvdimm_bus_register \
        '=drivers/nvdimm' \
        '=drivers/acpi' \
        '=arch/powerpc'
}

# called by dracut
install() {
    inst_multiple -o ndctl /etc/ndctl/keys/tpm.handle "/etc/ndctl/keys/*.blob"
}
