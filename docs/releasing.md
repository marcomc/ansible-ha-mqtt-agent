# Releasing

## Prerequisites

- A clean working tree on the default branch.
- Write access to `marcomc/ansible-ha-mqtt-agent` on GitHub.
- An Ansible Galaxy API token in the repository's local `.env` as
  `ANSIBLE_GALAXY_TOKEN`.
- A release version in `MAJOR.MINOR.PATCH` form.

## Preflight

Run the local validation suite:

```sh
uv run --with-requirements requirements-dev.txt ansible-lint .
uv run --with-requirements requirements-dev.txt molecule test
markdownlint --config "$HOME/.markdownlint.json" README.md CHANGELOG.md docs/*.md
```

Review `CHANGELOG.md` and add a dated entry for the release version, then commit
and push the release commit. Create and push the matching Git tag:

```sh
git tag -a vX.Y.Z -m "Release X.Y.Z"
git push origin vX.Y.Z
```

## Galaxy import

Ansible Galaxy imports standalone roles from GitHub tags. Start and check the
import after the tag is publicly available. From the repository root, load the
local release environment before running the authenticated Galaxy commands:

```sh
set -a
. ./.env
set +a
: "${ANSIBLE_GALAXY_TOKEN:?ANSIBLE_GALAXY_TOKEN must be set in .env}"
```

Then import and check the role:

```sh
ansible-galaxy role import marcomc ansible-ha-mqtt-agent \
  --branch main \
  --role-name ha_mqtt_agent \
  --token "$ANSIBLE_GALAXY_TOKEN"
ansible-galaxy role import --status marcomc ansible-ha-mqtt-agent \
  --token "$ANSIBLE_GALAXY_TOKEN"
ansible-galaxy role info marcomc.ha_mqtt_agent
```

Verify a pinned install in an empty directory:

```sh
roles_dir="$(mktemp -d)"
ansible-galaxy role install --roles-path "$roles_dir" marcomc.ha_mqtt_agent,vX.Y.Z
rm -rf "$roles_dir"
```

If the import is stale, verify the GitHub repository visibility, the default
branch, the pushed tag, and the Galaxy token before retrying.
