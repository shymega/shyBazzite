#!/usr/bin/env bash

set -euo pipefail

## ZFS (originally derived from https://github.com/shymega/shyBazzite-zfs-test/blob/main/build_files/build.sh)

RELEASE="$(rpm -E %fedora)"

# dnf install -y https://zfsonlinux.org/fedora/zfs-release-3-0$(rpm --eval "%{dist}").noarch.rpm
dnf install -y kernel-devel-"$(rpm -qa kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"
dnf install -y /opt/zfs-kmod-debugsource-2.4.99-224_g74b50a71a.fc43.x86_64.rpm
# dnf install -y zfs

## Auto-load ZFS module
depmod -a "$(rpm -qa kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')" && \
echo "zfs" > /etc/modules-load.d/zfs.conf && \

## we don't want any files on /var
rm -rf /var/lib/pcp

## Just in case, according to https://openzfs.github.io/openzfs-docs/Getting%20Started/Fedora/index.html#installation
echo 'zfs' > /etc/dnf/protected.d/zfs.conf

