INITRD="initrd.img-ubuntu"
DEST="root/boot"
fail() {
    echo $1 1>&2
    exit 1
}

echo "Copying ubuntu initrd..."

cp "/tmp/script/$INITRD" "$1/$DEST/" || fail "Failed to copy initrd!"
chown root:root "$1/$DEST/$INITRD"
chmod 755 "$1/$DEST/$INITRD"
