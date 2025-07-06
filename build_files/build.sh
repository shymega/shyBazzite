#!/usr/bin/env bash

set -ouex pipefail

### Install packages

## ZFS

RELEASE="$(rpm -E %fedora)"

### Install cached ZFS and appropriate kernel
rpm-ostree override replace /tmp/rpms/kernel/*.rpm /tmp/rpms/zfs/*.rpm
# Auto-load ZFS module
depmod -a "$(rpm -qa kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')" && \
echo "zfs" > /etc/modules-load.d/zfs.conf && \
# we don't want any files on /var
rm -rf /var/lib/pcp
## Just in case, according to https://openzfs.github.io/openzfs-docs/Getting%20Started/Fedora/index.html#installation
echo 'zfs' > /etc/dnf/protected.d/zfs.conf

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 install -y tmux 

dnf5 install -y python3-virtualenv python3-tkinter

curl -s https://raw.githubusercontent.com/zerotier/ZeroTierOne/master/doc/contact%40zerotier.com.gpg | sudo tee /etc/pki/rpm-gpg/RPM-GPG-KEY-zerotie

cat << 'EOF' | sudo tee /etc/yum.repos.d/zerotier.repo
[zerotier]
name=ZeroTier, Inc. RPM Release Repository
baseurl=http://download.zerotier.com/redhat/fc/$releasever
enabled=1
gpgcheck=1
EOF

dnf5 install -y zerotier-one
systemctl --now enable zerotier-one

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

systemctl enable podman.socket
