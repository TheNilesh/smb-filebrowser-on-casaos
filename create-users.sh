#!/usr/bin/env bash
set -e

BASE_DIR="/DATA/srv/users"
FAMILY_GROUP="family"

USERS=(
  bob
  alice
  john
  jane
)

echo "Creating family group if missing..."
getent group "$FAMILY_GROUP" >/dev/null || groupadd "$FAMILY_GROUP"

mkdir -p "$BASE_DIR"

for USER in "${USERS[@]}"; do
  echo "Creating user: $USER"

  if ! id "$USER" >/dev/null 2>&1; then
    useradd \
      -M \
      -N \
      -d "$BASE_DIR/$USER" \
      -s /usr/sbin/nologin \
      "$USER"
  fi

  usermod -aG "$FAMILY_GROUP" "$USER"

  mkdir -p "$BASE_DIR/$USER"
  chown "$USER:$FAMILY_GROUP" "$BASE_DIR/$USER"
  chmod 750 "$BASE_DIR/$USER"

  echo "✔ $USER -> $BASE_DIR/$USER"
done

echo "Done."
