FSTAB="root/etc/fstab"

echo "Removing fstab root mount..."
echo -e "$(cat $1/$FSTAB | grep -v '/dev/root')" > "$1/$FSTAB"