# Changelog

All notable changes to this role are documented here.

## [0.1.0] - 2026-07-15

- Initial standalone release of the Home Assistant MQTT Agent role.
- Added pinned source checkout, revision-based idempotence, and conditional
  invocation of the upstream systemd installer.
- Added managed or operator-managed secret configuration, desired service state,
  optional Raspberry Pi firmware checks, and MQTT connectivity validation.
- Added a Debian 13 Molecule scenario using a local test fixture instead of a
  live MQTT broker or production agent source.

[0.1.0]: https://github.com/marcomc/ansible-ha-mqtt-agent/releases/tag/0.1.0
