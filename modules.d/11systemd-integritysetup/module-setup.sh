#!/bin/bash
# This file is part of dracut.
# SPDX-License-Identifier: GPL-2.0-or-later

# Prerequisite check(s) for module.
check() {

    # If the binary(s) requirements are not fulfilled the module can't be installed.
    require_binaries \
        "$systemdutildir"/systemd-integritysetup \
        "$systemdutildir"/system-generators/systemd-integritysetup-generator \
        || return 1

    # Return 255 to only include the module, if another module requires it.
    return 255

}

# Module dependency requirements.
depends() {

    # This module has external dependency on other module(s).
    echo systemd dm
    # Return 0 to include the dependent module(s) in the initramfs.
    return 0

}

# Config adjustments before installing anything.
config() {
    add_dlopen_features+=" libsystemd-shared-*.so:cryptsetup "
}

# Install kernel module(s).
installkernel() {
    hostonly='' instmods dm-integrity
}

# Install the required file(s) and directories for the module in the initramfs.
install() {

    inst_multiple -o \
        "$systemdutildir"/systemd-integritysetup \
        "$systemdutildir"/system-generators/systemd-integritysetup-generator \
        "$systemdsystemunitdir"/remote-integritysetup.target \
        "$systemdsystemunitdir"/integritysetup-pre.target \
        "$systemdsystemunitdir"/integritysetup.target \
        "$systemdsystemunitdir"/sysinit.target.wants/integritysetup.target \
        "$systemdsystemunitdir"/initrd-root-device.target.wants/remote-integritysetup.target

    # Install the hosts local user configurations if enabled.
    if [[ ${hostonly-} ]]; then
        inst_multiple -H -o \
            /etc/integritytab \
            "$systemdsystemconfdir"/integritysetup.target \
            "$systemdsystemconfdir/integritysetup.target.wants/*.target" \
            "$systemdsystemconfdir"/integritysetup-pre.target \
            "$systemdsystemconfdir/integritysetup-pre.target.wants/*.target" \
            "$systemdsystemconfdir"/remote-integritysetup.target \
            "$systemdsystemconfdir/remote-integritysetup.target.wants/*.target" \
            "$systemdsystemconfdir"/sysinit.target.wants/integritysetup.target \
            "$systemdsystemconfdir/sysinit.target.wants/integritysetup.target.wants/*.target" \
            "$systemdsystemconfdir"/initrd-root-device.target.wants/remote-integritysetup.target
    fi

    # Install required libraries.
    _arch=${DRACUT_ARCH:-$(uname -m)}
    if [[ ! $USE_SYSTEMD_DLOPEN_DEPS ]]; then
        inst_libdir_file {"tls/$_arch/",tls/,"$_arch/",}"libcryptsetup.so.*"
    fi
}
