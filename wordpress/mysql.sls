{% set os_family = grains['os_family'] %}
{% set os_name = grains['os'] %}
{% set db_user = pillar.get('mysql:user', 'root') %}
{% set db_password = pillar.get('mysql:password', 'changeme') %}

{% if os_family == 'Suse' %}
mysql_install:
  pkg.installed:
    - name: mysql-community-server

mysql_service:
  service.running:
    - name: mysql
    - enable: True
    - require:
      - pkg: mysql_install

{% elif os_family == 'RedHat' %}
mysql_install:
  pkg.installed:
    - name: mysql-server

mysql_service:
  service.running:
    - name: mysqld
    - enable: True
    - require:
      - pkg: mysql_install

{% elif os_family == 'Debian' %}
mysql_install:
  pkg.installed:
    - name: mysql-server

mysql_service:
  service.running:
    - name: mysql
    - enable: True
    - require:
      - pkg: mysql_install
{% endif %}

mysql_secure:
  cmd.run:
    - name: mysql -e "ALTER USER '{{ db_user }}'@'localhost' IDENTIFIED BY '{{ db_password }}'; FLUSH PRIVILEGES;"
    - require:
      - service: mysql_service
