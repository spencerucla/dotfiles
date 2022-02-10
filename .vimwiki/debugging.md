# Contents
    - [Debugging](#Debugging)
        - [Building and flash/push dir](#Debugging#Building and flash/push dir)
        - [Kmsg](#Debugging#Kmsg)
            - [Write to kmsg from kernel](#Debugging#Kmsg#Write to kmsg from kernel)
            - [Allow init.te to write to kmsg](#Debugging#Kmsg#Allow init.te to write to kmsg)
            - [Write to kmsg from system/core/init/ daemon](#Debugging#Kmsg#Write to kmsg from system/core/init/ daemon)
            - [Write to kmsg from init.rc scripts](#Debugging#Kmsg#Write to kmsg from init.rc scripts)
            - [Write to kmsg from other scripts](#Debugging#Kmsg#Write to kmsg from other scripts)
        - [Logcat](#Debugging#Logcat)
            - [Write to logcat from Android app](#Debugging#Logcat#Write to logcat from Android app)
            - [Write to logcat from bash scripts](#Debugging#Logcat#Write to logcat from bash scripts)
        - [SELinux](#Debugging#SELinux)
            - [Disable runtime (non-persistent across reboot)](#Debugging#SELinux#Disable runtime (non-persistent across reboot))
        - [Tools](#Debugging#Tools)
            - [simg2img: extract system.img](#Debugging#Tools#simg2img: extract system.img)
            - [addr2line](#Debugging#Tools#addr2line)
        - [Crash dumps](#Debugging#Crash dumps)
            - [Free and null pointers on remove](#Debugging#Crash dumps#Free and null pointers on remove)
            - [Refcounting](#Debugging#Crash dumps#Refcounting)
        - [Other](#Debugging#Other)
            - [Cause Kernel Panic](#Debugging#Other#Cause Kernel Panic)
            - [ADB commands with multiple devices connected](#Debugging#Other#ADB commands with multiple devices connected)
            - [Other useful Android commands](#Debugging#Other#Other useful Android commands)

# Debugging

## Building and flash/push dir

Build just a dir
findmakefile
cd <that/dir>
mmp
- if static library (so), then need to rebuild everything that depends on it
  (regardless of java or not)
- if dynamic library (jar), can just push that jar
- if package (apk), can just push that apk

## Kmsg

### Write to kmsg from kernel
```C
pr_info("log message\n");
```

### Allow init.te to write to kmsg
```
userdebug_or_eng(`
allow init kmsg_device:chr_file write;
')
```

### Write to kmsg from system/core/init/ daemon
```C
#define KMSG(log)                               \
do {                                            \
    int kmsgfd = open("/dev/kmsg", O_WRONLY);   \
    write(kmsgfd, log, strlen(log));            \
    close(kmsgfd);                              \
} while (0)

KMSG("log message");
```

### Write to kmsg from init.rc scripts
```sh
write /dev/kmsg "log message"
```

### Write to kmsg from other scripts
```sh
echo "log message" > /dev/kmsg
```

## Logcat

### Write to logcat from Android app
```Java
import android.util.Log;
Log.i("TAG", "log message");
```

### Write to logcat from bash scripts
```sh
/vendor/bin/log -t "TAG" -p i "log message"
```

## SELinux

### Disable runtime (non-persistent across reboot)
```sh
adb root
adb shell setenforce 0
```

## Tools

### simg2img: extract system.img
```sh
$TOP/out/host/linux-x86/bin/simg2img system.img system.raw.img
mkdir /mnt/my_system /mnt/my_userdata
sudo mount -t ext4 -o loop system.raw.img /mnt/my_system
```

### addr2line
```sh
arm-linux-androideabi-addr2line -C -f -e obj/local/armeabi/libXXX.so <address>
```
```sh
$TOP/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android-addr2line -f -e $OUT/obj/KERNEL/vmlinux ffffffc00010de44
# last arg is the pointer is what's in PC
```
Notes
* aarch64-linux-android-addr2line must be the same toolchain as what the image
  was built with
* vmlinux must be the same as the image that the crash was from

## Crash dumps

### Free and null pointers on remove
Learned kernel debugging
[  333.292086] Unable to handle kernel paging request at virtual address 1eae8008
[16158.816224] [<ffffffc0009d2188>] iio_device_unregister_trigger_consumer+0x18/0x34
[16158.865614] [<ffffffc00093e7b8>] driver_remove+0x54/0x12c

It's not null, and this happens during the remove function so some pointer is
probably not being set to null
(since many other functions check for null before dereferencing)

Fix:
```C
kfree(p);
p = NULL;
```

### Refcounting

The traces here were in reference counting and it always seemed like the
resource was disappearing before done with it. That is a typical sign that
there is need for reference counting. We could've used
kobject_get(&indio_dev->dev.kobj) / kobject_put(&indio_dev->dev.kobj)
That seems to work, but iio_device_get/put also exist. Refcounting ensures that
your resource doesn't disappear until you call put, then it can destroy the
resource.

1324 [  144.919947] [<ffffffc00037ab5c>] strnlen+0x4/0x40
1325 [  144.924649] [<ffffffc00037da1c>] vsnprintf+0x300/0x764
1326 [  144.929781] [<ffffffc00037deac>] vscnprintf+0x2c/0x4c
1327 [  144.934828] [<ffffffc0000ab780>] vprintk_emit+0x194/0x4b4
1328 [  144.940221] [<ffffffc0000abad8>] vprintk+0x38/0x40
1329 [  144.945006] [<ffffffc0000a95b0>] warn_slowpath_fmt+0x98/0xc0
1330 [  144.950657] [<ffffffc0003744e4>] kobject_put+0x3c/0x6c
1331 [  144.955791] [<ffffffc0001a89fc>] cdev_put+0x18/0x2c
1332 [  144.960665] [<ffffffc0001a5c20>] __fput+0x12c/0x208
1333 [  144.965535] [<ffffffc0001a5d54>] ____fput+0xc/0x14
1334 [  144.970320] [<ffffffc0000cf018>] task_work_run+0xb8/0xf0
1335 [  144.975625] [<ffffffc0000894a8>] do_notify_resume+0x44/0x58

1376 [  224.389034] [<ffffffc00010de44>] module_put+0x54/0xf4
1377 [  224.394073] [<ffffffc0001a8a04>] cdev_put+0x20/0x2c
1378 [  224.398937] [<ffffffc0001a5c20>] __fput+0x12c/0x208
1379 [  224.403801] [<ffffffc0001a5d54>] ____fput+0xc/0x14
1380 [  224.408580] [<ffffffc0000cf018>] task_work_run+0xb8/0xf0
1381 [  224.413879] [<ffffffc0000ae810>] do_exit+0x3c4/0x968
1382 [  224.418831] [<ffffffc0000afec8>] do_group_exit+0xa0/0xdc
1383 [  224.424130] [<ffffffc0000bfef0>] get_signal_to_deliver+0x4a4/0x54c
1384 [  224.430295] [<ffffffc000088e78>] do_signal+0x94/0x4c8
1385 [  224.435331] [<ffffffc00008947c>] do_notify_resume+0x18/0x58

## Other

### Cause Kernel Panic
echo c >/proc/sysrq-trigger

### ADB commands with multiple devices connected
export ANDROID_SERIAL=<serial_from_adb_devices>

### Other useful Android commands
```sh
adb shell pm list packages | grep <...>
adb shell pm disable <...>
adb shell settings put system screen_off_timeout <...>
adb shell ps -t -P -p # threads
watch -n 0.5 "adb shell cat /proc/interrupts | grep irq"
```

### Apk version
```sh
aapt dump badging <apkfile> | grep version
```
