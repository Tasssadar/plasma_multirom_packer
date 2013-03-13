#!/bin/bash
INITRD="initrd.img-ubuntu"
ROOT_DEST="zip_root/rom"
ZIP_ROOT="zip_root"
ZIP_DEST="plasma.zip"

function echo_b {
    echo -e "\e[01;34m$1\e[00m"
}

function fail {
    echo -e "\e[01;31mFAILED: $1\e[00m"
    exit 1
}

if [ "$(whoami)" != "root" ] ; then
    echo "This script must be executed with root permissions!"
    exit 1
fi

img_addr=""
skip_to_pack=0
for i in $* ; do 
    case $i in
        --help)
            echo "Usage: $0 [options] [image URL]"
            echo ""
            echo "Options:"
            echo "    -s        - skip to image packing - no download, no extracting"
            echo "    --clean   - clean everything"
            exit 0
            ;;
        http*)
            img_addr="$i"
            ;;
        -s)
            skip_to_pack=1
            ;;
        --clean)
            echo_b "Cleaning working folder..."
            rm -r root
            rm "$ROOT_DEST"/root.tar.gz
            exit 0
    esac
done

if [ "$skip_to_pack" == "0" ] ; then
    if [ -z $img_addr ] ; then
        echo "You have to gimme image addres as arg!"
        exit 1
    fi

    if [ -d "root" ]; then 
        echo_b "Removing old root folder..."
        rm -rf root || fail "Failed to remove old root folder!"
    fi
    mkdir root
    cd root

    echo_b "Downloading image..."
    if [[ $img_addr == *tar.gz ]] ; then
        curl -L $img_addr | tar --numeric-owner -xz || fail "Failed to download the image!"
    elif [[ $img_addr == *tar.bz2 ]] ; then
        curl -L $img_addr | tar --numeric-owner -xj || fail "Failed to download the image!"
    else
        fail "Unknown image compression!"
    fi
else
    cd root
fi

echo_b "Copying ubuntu initrd..."
cp ../"$INITRD" boot/ || fail "Failed to copy initrd!"
chown root:root boot/"$INITRD"
chmod 755 boot/"$INITRD"

echo_b "Removing fstab root mount..."
echo -e "$(cat etc/fstab | grep -v '/dev/root')" > etc/fstab

echo_b "Compressing the root..."
if [ -e ../"$ROOT_DEST"/root.tar.gz ] ; then
    rm ../"$ROOT_DEST"/root.tar.gz || fail "Failed to remove old root.tar.gz!"
fi
tar --numeric-owner -zpcf ../"$ROOT_DEST"/root.tar.gz ./* || fail "Failed to compress the root!"

echo_b "Packing installation zip..."
cd "../$ZIP_ROOT" || fail "Failed to cd into ZIP\'s root!"
rm "$ZIP_DEST"
zip -0 -r ../$ZIP_DEST ./* || fail "Failed to create final ZIP!"

echo_b "Success!"
