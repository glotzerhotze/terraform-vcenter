#!/usr/bin/env bash

#
# Enable SSH-access for root
#
chmod -R go-rwx /root

if [ ! -d "/root/.ssh" ]; then
  mkdir /root/.ssh
fi

### Hook in for authorized root access
## cat << EOF > /root/.ssh/authorized_keys
## EOF

### Hook in for sshd configuration
## cat << EOF > /etc/ssh/sshd_config
## AcceptEnv LANG LC_*
## ChallengeResponseAuthentication no
## HostbasedAuthentication no
## HostKey /etc/ssh/ssh_host_dsa_key
## HostKey /etc/ssh/ssh_host_ecdsa_key
## HostKey /etc/ssh/ssh_host_ed25519_key
## HostKey /etc/ssh/ssh_host_rsa_key
## IgnoreRhosts yes
## KeyRegenerationInterval 3600
## LoginGraceTime 120
## LogLevel INFO
## MaxAuthTries 30
## PasswordAuthentication no
## PermitEmptyPasswords no
## PermitRootLogin yes
## PermitUserEnvironment yes
## Port 22
## PrintLastLog yes
## PrintMotd no
## Protocol 2
## PubkeyAuthentication yes
## RhostsRSAAuthentication no
## RSAAuthentication yes
## ServerKeyBits 1024
## StrictModes yes
## Subsystem sftp /usr/lib/openssh/sftp-server
## SyslogFacility AUTH
## TCPKeepAlive yes
## UsePAM yes
## UsePrivilegeSeparation yes
## X11DisplayOffset 10
## X11Forwarding yes
## EOF


#
# Reconfiguring Rsyslog to dump everything into /var/log/syslog
#
#### Ubuntu-specific
## rm -f /etc/rsyslog.d/20-ufw.conf
## echo "*.*;auth,authpriv.none          -/var/log/syslog" > /etc/rsyslog.d/50-default.conf

service rsyslog restart

#
# Remove obsolete log-files
#
#### Ubuntu-specific
## rm -f /var/log/wtmp
## rm -f /var/log/btmp
## rm -f /var/log/auth.log
## rm -f /var/log/cron.log
## rm -f /var/log/daemon.log
## rm -f /var/log/debug
## rm -f /var/log/kern.log
## rm -f /var/log/lpr.log
## rm -f /var/log/mail.err
## rm -f /var/log/mail.info
## rm -f /var/log/mail.log
## rm -f /var/log/mail.warn
## rm -f /var/log/messages
## rm -rf /var/log/news
## rm -f /var/log/ufw.log
## rm -f /var/log/user.log

#
# Update package data, remove unwanted packages, install needed base packages, clean APT-files and -caches
#
#### Ubuntu-specific
## export DEBCONF_FRONTEND=noninteractive
## apt-get update -y
## apt-get -y install curl wget cloud-initramfs-growroot

#### CentOS-specific
yum update -y
yum install -y epel-release
yum update -y
yum install -y curl wget python36 lvm2

## #
## # Unlocking password access for ubuntu user
## #
##
## echo "ubuntu:ubuntu" | chpasswd
##
## usermod -U ubuntu
##
## #
## # Infer local domain from meta data
## #
##
## host_name=""
## tenant_name=""
## search_domain=""
##
## if [ -x /usr/bin/jsonpointer ]; then
## 	host_name="$(echo '"/hostname"' | jsonpointer - /var/cache/comvel/meta_data.json)"
## 	host_name="${host_name#\"}"
## 	host_name="${host_name%%.*}"
##
## 	tenant_name="$(echo '"/meta/tenant"' | jsonpointer - /var/cache/comvel/meta_data.json)"
## 	tenant_name="${tenant_name#\"}"
## 	tenant_name="${tenant_name%\"}"
##
## 	case "$tenant_name" in
## 		comvel-admin|comvel-testing|comvel-staging|comvel-production)
## 			search_domain="${tenant_name#comvel-}.7tech.comvel.cloud"
## 		;;
## 	esac
## fi
##
## #
## # Add search domain overrides
## #
##
## if [ -e /etc/dhcp/dhclient.conf -a -n "$search_domain" ]; then
## 	for netdev in eth0 ens3; do
## 		[ -e "/sys/class/net/$netdev" ] || continue
##
## 		(
## 			echo "interface \"$netdev\" {"
## 			echo "	supersede domain-name \"$search_domain\";"
## 			echo "	supersede domain-search \"$search_domain\";"
## 			echo "}"
## 			echo ""
## 		) >> /etc/dhcp/dhclient.conf
##
## 		killall -9 dhclient
## 		ifup --force "$netdev"
## 	done
## fi
##
## #
## # Populate /etc/hosts
## #
##
## if [ -n "$host_name" -a -n "$search_domain" ]; then
## 	cat <<-EOT > /etc/hosts
## 		127.0.0.1 localhost
## 		127.0.1.1 $host_name.$search_domain $host_name
##
## 		# The following lines are desirable for IPv6 capable hosts
## 		::1 ip6-localhost ip6-loopback
## 		fe00::0 ip6-localnet
## 		ff00::0 ip6-mcastprefix
## 		ff02::1 ip6-allnodes
## 		ff02::2 ip6-allrouters
## 		ff02::3 ip6-allhosts
## 	EOT
## fi
##

#
# Prepare external volumes
#

read_volumes() {
	echo '
		import json

		with open("/root/metadata.json") as data_file:
		  data = json.load(data_file)

		if data["meta"]:
		  for k, v in sorted(data["meta"].items()):
		    if k.startswith("volume."):
		      print(k[7:] + "\t" + "\t".join(data["meta"][k].split(",")))

	' | sed -e 's/^\t\+//' | xargs -0 python36 -c
}

wait_for_device() {
	local dev="$1"
	local timeout="${2:-30}"

	while [ $((timeout--)) -gt 0 ]; do
		[ -b "/dev/$dev" ] && return 0
		sleep 1
	done

	return 1
}

find_next_vgname() {
	local index=1

	while true; do
		local name="$(printf "vg-%02d" $index)"

		if ! vgdisplay "$name" >/dev/null 2>/dev/null; then
			echo "$name"
			break
		fi

		index=$((index + 1))
	done
}

find_existing_vgname() {
	pvdisplay "$1" -c | cut -d: -f2
}

setup_volume() {
	local dev="$1"
	local dir="$2"
	local type="$3"

	local vgname
	local lvname="$(echo "$dir" | sed -e 's![^a-z0-9_]\+!-!g; s!^-!!; s!-$!!')"

	if ! wait_for_device "$dev" 30; then
		echo "Timeout waiting for device $dev to appear, aborting volume setup" >&2
		return 1
	fi

	if ! mkdir -p "$dir"; then
		echo "Unable to create mount point directory, aborting volume setup" >&2
		return 1
	fi

	local disktype="$(blkid -s TYPE -o value "/dev/$dev")"

	if [ "$type" = "lvm" ]; then
		if [ "$disktype" != "LVM2_member" ]; then
			vgname="$(find_next_vgname)"

			if ! pvcreate "/dev/$dev"; then
				echo "Unable to create physical volume, aborting volume setup" >&2
				return 1
			fi

			if ! vgcreate "$vgname" "/dev/$dev"; then
				echo "Unable to create volume group, aborting volume setup" >&2
				return 1
			fi

			if ! lvcreate "$vgname" --name "$lvname" --extents 100%FREE; then
				echo "Unable to create logical volume, aborting volume setup" >&2
				return 1
			fi

			if ! mkfs.ext4 -m 0 -L "$lvname" "/dev/$vgname/$lvname"; then
				echo "Unable to format logical volume, aborting volume setup" >&2
				return 1
			fi
		else
			vgname="$(find_existing_vgname "/dev/$dev")"

			if [ -z "$vgname" ]; then
				echo "Unable to resolve volume group name of /dev/$dev, aborting volume setup" >&2
				return 1
			fi
		fi

		echo "/dev/$vgname/$lvname $dir ext4 relatime 0 1" >> /etc/fstab

        vgchange -ay $vgname

		if ! mount "$dir"; then
			echo "Unable to mount logical volume, aborting volume setup" >&2
			return 1
		fi
	else
		if [ "$disktype" != "ext4" ]; then
			if ! mkfs.ext4 -m 0 -L "$lvname" "/dev/$dev"; then
				echo "Unable to format external volume, aborting volume setup" >&2
				return 1
			fi
		fi

		echo "/dev/$dev $dir ext4 relatime 0 1" >> /etc/fstab

		if ! mount "$dir"; then
			echo "Unable to mount external volume, aborting volume setup" >&2
			return 1
		fi
	fi

	return 0
}

read_volumes | while read volume; do
	set -- $volume

	if ! setup_volume "$@"; then
		echo "!!! Failed to setup volume $1 !!!" >&2
		continue
	fi
done

## #
## # (Re-)start SSH
## #
##
## service ssh start
