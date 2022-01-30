+++ 
draft = false
date = 2022-01-29T09:46:31-05:00
title = "Generic Cloud Images with Proxmox VE 7"
slug = "2022-01-proxmox-genericcloud-images"
tags = ['proxmox','virtualization','hypervisor','genericcloud','compute','homelab']
categories = ['Proxmox','Hypervisor','Compute','Automation','DevOps']
+++

If you've ever used [Proxmox](https://www.proxmox.com/en/proxmox-ve) as your hypervisor, you're likely familiar with process of downloading and mounting ISOs and installing it via the virtual KVM console. It's a pretty standard workflow. If you're smart about it, you might have even done that, installed `cloud-init` and the `qemu-guest-agent` and created a template VM you can easily clone to

What if I told you that you could utilize pre-built "Cloud" images from Ubuntu, Debian, Fedora, CentOS, Amazon, and more vendors? Okay, fine; I told you. A while ago, I built a [Puppet Bolt plan](https://github.com/danmanners/proxmox_api/blob/master/manifests/qemu/create_genericcloud.pp) to do "automagically," but I'd like to run anyone through doing it manually here.

The _real_ benefit of leveraging the Generic Cloud images is that you can go from "no virtual machine" to "I'm already provisioning things" in a matter of seconds, instead of many minutes. It's genuinely awesome. As you can see from the screenshot below, I've got plenty of Template VMs in my homelab Proxmox Cluster.

<center>
    <img src="static/images/posts/proxmox-genericcloud/pmx-dashboard.png" alt="Proxmox" style="margin: 20px 0px">
</center>

## Selecting your Generic Cloud Images, and...what is a Generic Cloud Image?

At a high level, Generic Cloud images are generally system disk images for whatever operating system built specifically for bog-standard KVM/QEMU hypervisors. Since Proxmox utilizes QEMU, we can run a few commands and do everything easily enough to have a template built for us for easy re-use!

Here are a few different sources you can use to find the Generic Cloud Image of your choice:

- [Ubuntu 20.04 LTS - Daily build](https://cloud-images.ubuntu.com/focal/current/)
- [Rocky Linux 8.5](https://download.rockylinux.org/pub/rocky/8/images/)
- [Fedora Linux - Release 35](https://mirrors.rit.edu/fedora/fedora/linux/releases/35/Cloud/x86_64/images/)
- [CentOS 7](https://cloud.centos.org/centos/7/images/)
- [openSUSE Leap 42.3 Ironic](https://download.opensuse.org/repositories/Cloud:/Images:/Leap_42.3/images/)

You can even add templates for systems like [OPNSense](https://opnsense.org/download/) if you use the `amd64`/`serial` image type. Super neat.

## Step 1 - Fetching your Generic Cloud Disk Image

First, you'll need to SSH to the Proxmox node you want to build the template on. Once you're there, `cd` to the `/tmp` directory. Then we'll want to fetch the image you want to use. For this guide, let's go with Ubuntu 20.04 LTS.

```bash
root@pmx:~# cd /tmp/
root@pmx:/tmp# wget https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64-disk-kvm.img -O ubuntu-2004.img
--2022-01-29 14:48:30--  https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64-disk-kvm.img
Resolving cloud-images.ubuntu.com (cloud-images.ubuntu.com)... 91.189.88.247, 91.189.88.248, 2001:67c:1360:8001::33, ...
Connecting to cloud-images.ubuntu.com (cloud-images.ubuntu.com)|91.189.88.247|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 561774592 (536M) [application/octet-stream]
Saving to: ‘ubuntu-2004.img’

ubuntu-2004.img                       83%[========================================================>            ] 446.88M  17.5MB/s    eta 5s     ^ubuntu-2004.img                      100%[====================================================================>] 535.75M  15.8MB/s    in 31s

2022-01-29 14:49:01 (17.5 MB/s) - ‘ubuntu-2004.img’ saved [561774592/561774592]

root@pmx:/tmp# 
```

We can validate the file format of the image by running `file`:

```bash
root@pmx:/tmp# file ubuntu-2004.img
ubuntu-2004.img: QEMU QCOW2 Image (v2), 2361393152 bytes
```

If the `file` command says it's a `qcow2` image format, you're good to continue to Step 2. If it says something else, you'll need to use `qemu-img` to convert it to a `qcow2` image format. You can see what this process might look like using the Ubuntu 20.04 image below.

```bash
root@pmx:/tmp# wget https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.vmdk -O ubuntu-2004.vmdk
--2022-01-29 15:59:56--  https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.vmdk
Resolving cloud-images.ubuntu.com (cloud-images.ubuntu.com)... 91.189.88.247, 91.189.88.248, 2001:67c:1360:8001::34, ...
Connecting to cloud-images.ubuntu.com (cloud-images.ubuntu.com)|91.189.88.247|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 564585472 (538M)
Saving to: ‘ubuntu-2004.vmdk’

ubuntu-2004.vmdk                     100%[====================================================================>] 538.43M  32.8MB/s    in 17s

2022-01-29 16:00:14 (31.7 MB/s) - ‘ubuntu-2004.vmdk’ saved [564585472/564585472]

root@pmx:/tmp# file ubuntu-2004.vmdk
ubuntu-2004.vmdk: VMware4 disk image

root@pmx:/tmp# qemu-img convert -p -f vmdk -O qcow2 \
    ubuntu-2004.vmdk ubuntu-2004.qcow2
    (100.00/100%)
```

## Step 2 - Creating your Virtual Machine Template

You can do this either through the Web UI or the terminal, but here are how you should go about doing this via the terminal.

```bash
# Set this to your Proxmox host name; it's case sensitive!
export ProxmoxHost="pmx"
# Set this to the correct network bridge; for most people it should be vmbr0.
export ProxmoxNetworkBridge="vmbr0"
# Set the name of the Storage Volume for Proxmox
export ProxmoxStorageVolume="pmx_os"
# Set the name of the Storage Volume Path
export ProxmoxStoragePath="/mnt/pve/${ProxmoxStorageVolume}/"
# Set this to the Virtual Machine ID you want to set your template to.
export VMID="9001"
# Set the default Disk Size
export DiskSize="16"
# VM Template Name
export TEMPLATE_NAME="Ubuntu-2004-Template"
# Set your SSH PublicKey
export SSHPUBKEY="Put your SSH Public Key here"
# Set your qcow2 Disk Image Path
export DiskPath="/tmp/ubuntu-2004.img"
# Set your Template Cloud-Init user name
export TemplateUser="ubuntu"

# Create your VM Template
pvesh create /nodes/${ProxmoxHost}/qemu \
    --serial0=socket --vga=serial0 \
    --boot=c --agent=1 \
    --bootdisk=scsi0 \
    --net0='model=e1000,bridge='${ProxmoxNetworkBridge}'' \
    --ide2=${ProxmoxStorageVolume}:cloudinit \
    --sockets=1 --cores=2 --memory=2048 \
    -scsihw='virtio-scsi-pci' \
    --ostype=l26 --numa 0 \
    --template=1 \
    --name=${TEMPLATE_NAME} \
    --vmid=${VMID}

# Ensure that `jq` is installed on your system
sudo apt install jq -y

# Import the disk image
qm importdisk ${VMID} ${DiskPath} ${ProxmoxStorageVolume} -f qcow2

# Mount the disk image and set the Cloud-Init settings
pvesh set /nodes/${ProxmoxHost}/qemu/${VMID}/config \
    --scsi0=${ProxmoxStorageVolume}:${VMID}/vm-${VMID}-disk-0.qcow2 \
    -ipconfig0='ip=dhcp' \
    --ciuser="${TemplateUser}" \
    --sshkeys="$(printf %s "${SSHPUBKEY}" | jq -sRr @uri)"

# Set the boot drive size
pvesh set /nodes/pmx/qemu/${VMID}/resize \
    -disk=scsi0 --size="${DiskSize}G"
```

The above commands are:

- Creating the Virtual Machine template with some default settings
- Ensuring that `jq` is installed onto the Proxmox node
- Importing the appropriate `qcow2` disk image
- Setting the `cloud-init` User name, Public Key, IP Address, and attaching the disk image
- Resizing the disk image to the desired size

Verify that all of the commands above completed successfully, and you're good to move forward!

## Step 3 - Using your new template!

Back in the Web UI, you can right-click on on the template you've just created and click 'Clone'.

<center>
    <img src="static/images/posts/proxmox-genericcloud/pmx-cloning.png" alt="Proxmox" style="margin: 20px 0px">
</center>

Simply fill out the required fields and click Clone.

<center>
    <img src="static/images/posts/proxmox-genericcloud/pmx-clone-template.png" alt="Proxmox" style="margin: 20px 0px">
</center>

Once the VM is successfully cloned, you can make any additional changes you may want through the Web UI. Click start, and then open the console. You'll be able to validate that the VM turns on, and you'll never need an ISO!

<center>
    <img src="static/images/posts/proxmox-genericcloud/pmx-console.png" alt="Proxmox" style="margin: 20px 0px">
</center>

That's it! Now you can repeat the steps above with any of the other Generic Cloud images you want! If you ever want to update/upgrade a given Generic Cloud image, you can re-do the steps above with a new URL for the disk image.

## Questions? Thoughts?

If something I wrote isn't clear, feel free to ask me a question or ask me to update it! You can ping me at [daniel.a.manners@gmail.com](mailto:daniel.a.manners@gmail.com), or tweet me [@damnanners](https://twitter.com/DamNanners).
