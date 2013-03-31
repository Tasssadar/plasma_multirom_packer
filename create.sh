#!/bin/bash
ROOT_DEST="zip_root/rom/root.tar.gz"
ZIP_ROOT="zip_root"
ZIP_DEST="plasma_"

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
            rm "$ROOT_DEST"
            exit 0
    esac
done

if [ "$skip_to_pack" == "0" ] ; then
    if [ -z $img_addr ] ; then
        echo "You have to gimme image addres as arg!"
        exit 1
    fi

    if [ -e "$ROOT_DEST" ]; then 
        echo_b "Removing old root.tar.gz..."
        rm -f "$ROOT_DEST" || fail "Failed to remove old root.tar.gz!"
    fi

    echo_b "Downloading image..."
    if [[ $img_addr == *tar.gz ]] ; then
        curl -L $img_addr > "$ROOT_DEST" || fail "Failed to download the image!"
    elif [[ $img_addr == *tar.bz2 ]] ; then
        curl -L $img_addr | bzip2 -d | gzip > "$ROOT_DEST" || fail "Failed to download the image!"
    else
        fail "Unknown image compression!"
    fi
fi

echo_b "Packing installation zip..."
cd "$ZIP_ROOT" || fail "Failed to cd into ZIP\'s root!"

zip_name="../${ZIP_DEST}$(date +%Y%m%d).mrom"
if [ -r $zip_name ]; then
    rm $zip_name
fi
zip -0 -r $zip_name ./* || fail "Failed to create final ZIP!"

echo_b "Success!"
