{%- set p = salt['pillar.get']('suma_wordpress')  %}
{%- if p is defined and
    p.mariadb is defined %}
{%- set mariadb = p.mariadb %}
{%- set os_family         = salt['grains.get']('os_family', None) %}
{%- set db_admin_user     = mariadb["db_admin_user"] %}
{%- set db_admin_password = mariadb["db_admin_password"] %}
{%- if os_family == 'Suse' %}
{%- set mariadb_pkg_name = "mariadb" %}
{%- set mariadb_svc_name = "mariadb.service" %}
{%- elif os_family == 'RedHat' %}
{%- set mariadb_pkg_name = "mariadb" %}
{%- set mariadb_svc_name = "mariadb.service" %}
{%- elif os_family == 'Debian' %}
{%- set mariadb_pkg_name = "mysql-server" %}
{%- set mariadb_svc_name = "mysql-server.service" %}
{%- endif %}

database_install:
  pkg.installed:
    - name: {{ mariadb_pkg_name }}

database_service:
  service.running:
    - name: {{ mariadb_svc_name }}
    - enable: True
    - require:
      - pkg: {{ mariadb_pkg_name }}

database_secure:
  cmd.run:
    - name: mysql -e "ALTER USER '{{ db_admin_user }}'@'localhost' IDENTIFIED BY '{{ db_admin_password }}'; FLUSH PRIVILEGES;"
    - require:
      - service: {{ mariadb_svc_name }}

database_password_file:
  file.managed:
    - name: /etc/my.cnf.d/90-salt.cnf
    - contents: |
        [client]
        user={{ db_admin_user }}
        password={{ db_admin_password }}
    - user: root
    - group: root
    - mode: '0400'
    - require:
      - id: database_secure

{%- endif %}
