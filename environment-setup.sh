#!/bin/bash
BULD_DIR=${BUILD_DIR}
if [ "${BULD_DIR}" = "" ]; then
  BULD_DIR=$(pwd)/build
  echo "BUILD_DIR not set, defaulting to a new directory here, ${BUILD_DIR}"
else
  echo "BUILD_DIR set to ${BUILD_DIR}"
fi

SOURCE_DIR=${SOURCE_DIR}
if [ "${SOURCE_DIR}" = "" ]; then
  SOURCE_DIR=$(pwd)/source
  echo "SOURCE_DIR not set, defaulting to a new directory here, ${SOURCE_DIR}"
else
  echo "SOURCE_DIR set to ${SOURCE_DIR}"
fi

if [ -d "${BUILD_DIR}" ]; then
  rm -rf ${BUILD_DIR}
fi

mkdir -pv ${BUILD_DIR}

if [ -d "${SOURCE_DIR}" ]; then
  rm -rf ${SOURCE_DIR}
fi

mkdir -pv ${SOURCE_DIR}

echo "Root directories ready"

set +h
umask 022
LC_ALL=POSIX
PATH=${BUILD_DIR}/cross-tools/bin:/bin:/usr/bin:/sbin:/usr/sbin

export BUILD_DIR SOURCE_DIR PATH LC_ALL

echo "Environment variables ready"

mkdir -pv ${BUILD_DIR}/{bin,boot{,grub},dev,{etc/,}opt,home,lib/{firmware,modules},lib64,mnt}
mkdir -pv ${BUILD_DIR}/{proc,media/{floppy,cdrom},sbin,srv,sys}
mkdir -pv ${BUILD_DIR}/var/{lock,log,mail,run,spool}
mkdir -pv ${BUILD_DIR}/var/{opt,cache,lib/{misc,locate},local}
install -dv -m 0750 ${BUILD_DIR}/root
install -dv -m 1777 ${BUILD_DIR}{/var,}/tmp
install -dv ${BUILD_DIR}/etc/init.d
mkdir -pv ${BUILD_DIR}/usr/{,local/}{bin,include,lib{,64},sbin,src}
mkdir -pv ${BUILD_DIR}/usr/{,local/}share/{doc,info,locale,man}
mkdir -pv ${BUILD_DIR}/usr/{,local/}share/{misc,terminfo,zoneinfo}
mkdir -pv ${BUILD_DIR}/usr/{,local/}share/man/man{1,2,3,4,5,6,7,8}

for dir in ${BUILD_DIR}/usr{,/local}; do
  ln -sv share/{man,doc,info} ${dir}
done

install -dv ${BUILD_DIR}/cross-tools{,/bin}
ln -svf ../proc/mounts ${BUILD_DIR}/etc/mtab

echo "Folder tree ready"

cat > ${BUILD_DIR}/etc/passwd << "EOF"
root::0:0:root:/root:/bin/ash
EOF

cat > ${BUILD_DIR}/etc/group << "EOF"
root:x:0:
bin:x:1:
sys:x:2:
kmem:x:3:
tty:x:4:
daemon:x:6:
disk:x:8:
dialout:x:10:
video:x:12:
utmp:x:13:
usb:x:14:
EOF

cat > ${BUILD_DIR}/etc/fstab << "EOF"
# file system  mount-point  type   options          dump  fsck
#                                                         order

rootfs          /               auto    defaults        1      1
proc            /proc           proc    defaults        0      0
sysfs           /sys            sysfs   defaults        0      0
devpts          /dev/pts        devpts  gid=4,mode=620  0      0
tmpfs           /dev/shm        tmpfs   defaults        0      0
EOF

cat > ${BUILD_DIR}/etc/profile << "EOF"
export PATH=/bin:/usr/bin

if [ `id -u` -eq 0 ] ; then
        PATH=/bin:/sbin:/usr/bin:/usr/sbin
        unset HISTFILE
fi


# Set up some environment variables.
export USER=`id -un`
export LOGNAME=$USER
export HOSTNAME=`/bin/hostname`
export HISTSIZE=1000
export HISTFILESIZE=1000
export PAGER='/bin/more '
export EDITOR='/bin/vi'
EOF

echo "darkbien-min" > ${BUILD_DIR}/etc/HOSTNAME

cat > ${BUILD_DIR}/etc/issue<< "EOF"
Linux Journal OS 0.1a
Kernel \r on an \m

EOF

cat > ${BUILD_DIR}/etc/inittab<< "EOF"
::sysinit:/etc/rc.d/startup

tty1::respawn:/sbin/getty 38400 tty1
tty2::respawn:/sbin/getty 38400 tty2
tty3::respawn:/sbin/getty 38400 tty3
tty4::respawn:/sbin/getty 38400 tty4
tty5::respawn:/sbin/getty 38400 tty5
tty6::respawn:/sbin/getty 38400 tty6

::shutdown:/etc/rc.d/shutdown
::ctrlaltdel:/sbin/reboot
EOF

cat > ${BUILD_DIR}/etc/mdev.conf<< "EOF"
# Devices:
# Syntax: %s %d:%d %s
# devices user:group mode

# null does already exist; therefore ownership has to
# be changed with command
null    root:root 0666  @chmod 666 $MDEV
zero    root:root 0666
grsec   root:root 0660
full    root:root 0666

random  root:root 0666
urandom root:root 0444
hwrandom root:root 0660

# console does already exist; therefore ownership has to
# be changed with command
console root:tty 0600 @mkdir -pm 755 fd && cd fd && for x in 0 1 2 3 ; do ln -sf /proc/self/fd/$x $x; done

kmem    root:root 0640
mem     root:root 0640
port    root:root 0640
ptmx    root:tty 0666

# ram.*
ram([0-9]*)     root:disk 0660 >rd/%1
loop([0-9]+)    root:disk 0660 >loop/%1
sd[a-z].*       root:disk 0660 */lib/mdev/usbdisk_link
hd[a-z][0-9]*   root:disk 0660 */lib/mdev/ide_links

tty             root:tty 0666
tty[0-9]        root:root 0600
tty[0-9][0-9]   root:tty 0660
ttyO[0-9]*      root:tty 0660
pty.*           root:tty 0660
vcs[0-9]*       root:tty 0660
vcsa[0-9]*      root:tty 0660

ttyLTM[0-9]     root:dialout 0660 @ln -sf $MDEV modem
ttySHSF[0-9]    root:dialout 0660 @ln -sf $MDEV modem
slamr           root:dialout 0660 @ln -sf $MDEV slamr0
slusb           root:dialout 0660 @ln -sf $MDEV slusb0
fuse            root:root  0666

# misc stuff
agpgart         root:root 0660  >misc/
psaux           root:root 0660  >misc/
rtc             root:root 0664  >misc/

# input stuff
event[0-9]+     root:root 0640 =input/
ts[0-9]         root:root 0600 =input/

# v4l stuff
vbi[0-9]        root:video 0660 >v4l/
video[0-9]      root:video 0660 >v4l/

# load drivers for usb devices
usbdev[0-9].[0-9]       root:root 0660 */lib/mdev/usbdev
usbdev[0-9].[0-9]_.*    root:root 0660
EOF

cat > ${BUILD_DIR}/boot/grub/grub.cfg<< "EOF"

set default=0
set timeout=5

set root=(hd0,1)

menuentry "Darkbein Minimal OS 0.1a" {
        linux   /boot/vmlinuz-4.16.3 root=/dev/sda1 ro quiet
}
EOF

touch ${BUILD_DIR}/var/run/utmp ${BUILD_DIR}/var/log/{btmp,lastlog,wtmp}
chmod -v 664 ${BUILD_DIR}/var/run/utmp ${BUILD_DIR}/var/log/lastlog

echo "Files and configurations set up"

unset CFLAGS
unset CXXFLAGS

export BUILD_DIR_HOST=$(echo ${MACHTYPE} | sed "s/-[^-]*/-cross/")
export BUILD_DIR_TARGET=x86_64-unknown-linux-gnu
export BUILD_DIR_CPU=k8
export BUILD_DIR_ARCH=$(echo ${BUILD_DIR_TARGET} | sed -e 's/-.*//' -e 's/i.86/i386/')
export BUILD_DIR_ENDIAN=little

echo "Final setup of environment needed for cross-compiling done"

echo "Next step: source download-all.sh"