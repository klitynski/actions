#!/bin/sh

set -e

SSH_PATH="$HOME/.ssh"
BRANCH="$(echo "$GITHUB_REF" | sed "s/^refs\/heads\///")"

mkdir -p "$SSH_PATH"
touch "$SSH_PATH/known_hosts"

echo "$PRIVATE_KEY" > "$SSH_PATH/deploy_key"

chmod 700 "$SSH_PATH"
chmod 600 "$SSH_PATH/known_hosts"
chmod 600 "$SSH_PATH/deploy_key"

eval $(ssh-agent)
ssh-add "$SSH_PATH/deploy_key"

ssh-keyscan -t rsa $HOST >> "$SSH_PATH/known_hosts"

ssh -o StrictHostKeyChecking=no -A -tt -p ${PORT:-22} $USER@$HOST "apps:clone --ignore-existing --skip-deploy "develop" "$BRANCH""

git remote add develop $USER@$HOST:$BRANCH
git push develop HEAD:master --force
