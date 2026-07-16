#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

project_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
defer_start=false

for argument in "$@"; do
  case "${argument}" in
    --help)
      printf '%s\n' 'Usage: install.sh [--non-interactive] [--no-start]'
      exit 0
      ;;
    --no-start)
      defer_start=true
      ;;
    --non-interactive)
      ;;
    *)
      printf 'Unsupported argument: %s\n' "${argument}" >&2
      exit 2
      ;;
  esac
done

printf '%s\n' 'install' >> /var/tmp/ha-mqtt-agent-probes/installer.log

if ! getent group ha-mqtt-agent >/dev/null; then
  groupadd --system ha-mqtt-agent
fi

if ! id ha-mqtt-agent >/dev/null 2>&1; then
  useradd --system --gid ha-mqtt-agent --shell /usr/sbin/nologin ha-mqtt-agent
fi

install --directory --owner root --group ha-mqtt-agent --mode 0750 /etc/ha-mqtt-agent
install --directory --owner root --group root --mode 0755 /opt/ha-mqtt-agent
install --mode 0755 "${project_root}/scripts/ha-mqtt-agent-test" /usr/local/bin/ha-mqtt-agent

cat >/etc/systemd/system/ha-mqtt-agent.service <<'UNIT'
[Unit]
Description=Home Assistant MQTT Agent fixture

[Service]
Type=simple
User=ha-mqtt-agent
Group=ha-mqtt-agent
ExecStart=/usr/local/bin/ha-mqtt-agent run

[Install]
WantedBy=multi-user.target
UNIT

systemctl daemon-reload

if [[ "${defer_start}" = false ]]; then
  systemctl enable --now ha-mqtt-agent
fi
