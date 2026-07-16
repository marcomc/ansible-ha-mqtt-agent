# Ansible Role: ha_mqtt_agent

Install [Home Assistant MQTT Agent](https://github.com/marcomc/ha-mqtt-agent)
through its upstream systemd installer.

## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Role Variables](#role-variables)
- [Example Playbook](#example-playbook)
- [Configuration Management](#configuration-management)
- [Testing](#testing)
- [Release](#release)
- [License](#license)

## Requirements

| Requirement | Value |
| --- | --- |
| Target OS | Debian 12 or 13 |
| Ansible | `ansible-core >= 2.15` |
| Privilege escalation | Required |
| Target network | Access to the agent source, Debian repositories, PyPI, and MQTT broker |

The role delegates runtime, account, config bootstrap, and systemd unit
installation to the agent's upstream installer. A revision marker avoids
re-running that installer when the checkout and installed artifacts are current.

## Installation

After the role is published to Galaxy, install a pinned release:

```sh
ansible-galaxy role install marcomc.ha_mqtt_agent,0.1.1
```

Before the first Galaxy import, use Git directly:

```yaml
---
roles:
  - name: marcomc.ha_mqtt_agent
    src: https://github.com/marcomc/ansible-ha-mqtt-agent.git
    version: main
```

## Role Variables

| Variable | Default | Description |
| --- | --- | --- |
| `ha_mqtt_agent_repo_url` | `https://github.com/marcomc/ha-mqtt-agent.git` | Agent source repository |
| `ha_mqtt_agent_repo_version` | `main` | Branch, tag, or commit to install |
| `ha_mqtt_agent_expected_version` | empty | Optional installed-version assertion |
| `ha_mqtt_agent_force_install` | `false` | Re-run the upstream installer |
| `ha_mqtt_agent_installer_arguments` | `['--non-interactive']` | Installer arguments |
| `ha_mqtt_agent_installer_defer_start` | `true` | Use `--no-start` when supported |
| `ha_mqtt_agent_config_management` | `unmanaged` | `managed` or `unmanaged` |
| `ha_mqtt_agent_config_content` | empty | Complete TOML for managed mode |
| `ha_mqtt_agent_config_required` | `true` | Require a non-empty config file |
| `ha_mqtt_agent_service_enabled` | `true` | Enable the service at boot |
| `ha_mqtt_agent_service_state` | `started` | Desired service state |
| `ha_mqtt_agent_enable_raspberry_pi_firmware` | `false` | Enable `vcgencmd` telemetry checks |
| `ha_mqtt_agent_enable_raspberry_pi_pmic_voltage` | `false` | Validate Pi 5 `EXT5V_V` |
| `ha_mqtt_agent_validate_mqtt` | `false` | Run `doctor --mqtt` as the service user |

See [defaults/main.yml](defaults/main.yml) and
[meta/argument_specs.yml](meta/argument_specs.yml) for the complete API.

## Example Playbook

```yaml
---
- name: Install Home Assistant MQTT Agent
  hosts: linux_hosts
  become: true
  roles:
    - role: marcomc.ha_mqtt_agent
      vars:
        ha_mqtt_agent_repo_version: COMMIT_SHA
        ha_mqtt_agent_config_management: unmanaged
        ha_mqtt_agent_enable_raspberry_pi_firmware: true
```

Enable `ha_mqtt_agent_enable_raspberry_pi_pmic_voltage` only on Raspberry Pi
5-family hosts that expose `vcgencmd pmic_read_adc EXT5V_V`.

## Configuration Management

| Mode | Behavior |
| --- | --- |
| `managed` | Rewrites the config from `ha_mqtt_agent_config_content` |
| `unmanaged` | Preserves the host config and enforces secure metadata |

Keep MQTT credentials outside version control. Managed config content is marked
`no_log`; both modes set ownership to `root:ha-mqtt-agent` and mode `0640`.

## Testing

Install the test dependencies and run the test scenario:

```sh
uv venv --python 3.13
uv pip install --python .venv/bin/python -r requirements-dev.txt
.venv/bin/ansible-galaxy collection install -r molecule/default/collections.yml
.venv/bin/ansible-lint .
.venv/bin/molecule test
```

Molecule uses a local Git fixture and a mock installer, so it never contacts an
MQTT broker or the production agent repository. It validates installation,
service state, managed configuration, revision tracking, idempotence, and a
post-convergence check-mode run. The check-mode regression verifies version,
firmware, PMIC-voltage, MQTT, and service-state probes while confirming it does
not reinstall the agent, rewrite configuration, restart the service, or change
the revision marker. Docker must be running.

## Release

See [docs/releasing.md](docs/releasing.md) for the GitHub-tag and Ansible Galaxy
import workflow.

## License

MIT. See [LICENSE](LICENSE).
