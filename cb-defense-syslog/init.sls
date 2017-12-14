{# cb_defense_syslog #}

{# process from https://developer.carbonblack.com/2017/06/cb-defense-syslog-connector-1.2.3-released/ #}

{% from "cb-defense-syslog/map.jinja" import cb_defense_syslog_settings with context %}

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

{% if 'cron' in cb_defense_syslog_settings and cb_defense_syslog_settings.cron.manage == True and cb_defense_syslog_settings.cron.task.items() != {} %}
cron-cb-defense-syslog:
  cron.present:
    {% if not 'name' in cb_defense_syslog_settings.cron.task %}
    - name: /usr/share/cb/integrations/cb-defense-syslog/cb-defense-syslog --config-file {{ cb_defense_syslog_settings.lookup.locations.config_dir }}/cb-defense-syslog.conf --log-file {{ cb_defense_syslog_settings.lookup.locations.log_dir }}/cb-defense-syslog.log
    {% endif %}
    {% if not 'identifier' in cb_defense_syslog_settings.cron.task %}
    - identifier: SALT-CB-DEFENSE-SYSLOG
    {% endif %}
    {% if not 'user' in cb_defense_syslog_settings.cron.task %}
    - user: root
    {% endif %}
    {% if not 'minute' in cb_defense_syslog_settings.cron.task %}
    - minute: '0'
    {% endif %}
    {% for name, value in cb_defense_syslog_settings.cron.task.items() %}
    - {{ name }}: '{{ value }}'
    {% endfor %}
    - require:
      - pkg: cb-defense-syslog-pkgs
      - file: {{ cb_defense_syslog_settings.lookup.locations.log_dir }}
      - file: {{ cb_defense_syslog_settings.lookup.locations.config_dir }}/cb-defense-syslog.conf
{% endif %}

{# EOF #}
