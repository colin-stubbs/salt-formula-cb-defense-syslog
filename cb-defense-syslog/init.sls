{# cb_defense_syslog #}

{# process from https://developer.carbonblack.com/2017/06/cb-defense-syslog-connector-1.2.3-released/ #}

{% from "cb_defense_syslog/map.jinja" import cb_defense_syslog_settings with context %}

cb-open-source-repo:
  file.managed:
    - name: /etc/yum.repos.d/CbOpenSource.repo
    - source: https://opensource.carbonblack.com/release/x86_64/CbOpenSource.repo
    - user: root
    - group: root
    - mode: 0644

cb-defense-syslog-pkgs:
  pkg.installed:
    - pkgs: {{ cb_defense_syslog_settings.lookup.pkgs }}
    - require:
      - file: cb-open-source-repo

{{ cb_defense_syslog_settings.lookup.locations.log_dir }}:
  file.directory:
    - makedirs: True
    - user: root
    - group: root
    - mode: 0750
    - require:
      - pkg: cb-defense-syslog-pkgs

{{ cb_defense_syslog_settings.lookup.locations.config_dir }}/cb-defense-syslog.conf:
  file.managed:
    - source: salt://cb-defense-syslog/files/cb-defense-syslog.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 0640
    - require:
      - pkg: cb-defense-syslog-pkgs

cron-cb-defense-syslog:
  cron.present:
    - name: /usr/share/cb/integrations/cb-defense-syslog/cb-defense-syslog --config-file {{ cb_defense_syslog_settings.lookup.locations.config_dir }}/cb-defense-syslog.conf --log-file {{ cb_defense_syslog_settings.lookup.locations.log_dir }}/cb-defense-syslog.log
    - identifier: SALT-CB-DEFENSE-SYSLOG
    - user: root
    - minute: 0
    - require:
      - pkg: cb-defense-syslog-pkgs
      - file: {{ cb_defense_syslog_settings.lookup.locations.log_dir }}
      - file: {{ cb_defense_syslog_settings.lookup.locations.config_dir }}/cb-defense-syslog.conf

{# EOF #}
