# Fetch ZFS RPMs
skopeo copy --retry-times 3 docker://ghcr.io/ublue-os/akmods-zfs:"${AKMODS_FLAVOR}"-"$(rpm -E %fedora)"-"${KERNEL}" dir:/tmp/akmods-zfs
ZFS_TARGZ=$(jq -r '.layers[].digest' < /tmp/akmods-zfs/manifest.json | cut -d : -f 2)
tar -xvzf /tmp/akmods-zfs/"$ZFS_TARGZ" -C /tmp/
mv /tmp/rpms/* /tmp/akmods-zfs/

# Declare ZFS RPMs
ZFS_RPMS=(
    /tmp/akmods-zfs/kmods/zfs/kmod-zfs-"${KERNEL}"-*.rpm
        /tmp/akmods-zfs/kmods/zfs/libnvpair3-*.rpm
        /tmp/akmods-zfs/kmods/zfs/libuutil3-*.rpm
        /tmp/akmods-zfs/kmods/zfs/libzfs5-*.rpm
        /tmp/akmods-zfs/kmods/zfs/libzpool5-*.rpm
        /tmp/akmods-zfs/kmods/zfs/python3-pyzfs-*.rpm
        /tmp/akmods-zfs/kmods/zfs/zfs-*.rpm
        pv
    )

    # Install
    rpm-ostree install "${ZFS_RPMS[@]}"

    # Depmod and autoload
    depmod -a -v "${KERNEL}"
    echo "zfs" > /usr/lib/modules-load.d/zfs.conf
fi
