{%- set p = salt['pillar.get']('suma_wordpress')  %}
{%- if p is defined and
    p.apache is defined and
    p.wordpress is defined %}
{%- set apache          = p.apache %}
{%- set wp              = p.wordpress %}
{%- set os_family       = salt['grains.get']('os_family', None) %}
{%- set directory_root  = apache["directory_root"] %}
{%- set directory_owner = apache["directory_owner"] %}
{%- set directory_group = apache["directory_group"] %}
{%- set wp_db_name      = wp["wordpress_database"] %}
{%- set wp_db_user      = wp["wordpress_db_username"] %}
{%- set wp_db_passwd    = wp["wordpress_db_password"] %}
{%- if os_family == 'Suse' %}
{%- set wp_pkgs         = ["php8", "php8-mysql", "php8-gd"] %}
{%- elif os_family == 'RedHat' %}
{%- set wp_pkgs         = ["php", "php-mysql", "php-gd"] %}
{%- elif os_family == 'Debian' %}
{%- set wp_pkgs         = ["php", "php-mysql", "php-gd"] %}
{%- endif %}

{%- if wp_pkgs|length > 0 %}
php_install:
  pkg.installed:
    - pkgs:
      {%- for pkg in wp_pkgs %}
      - {{ pkg.strip() }}
      {%- endfor %}
{%- endif %}

download_wordpress:
  cmd.run:
    - name: wget -O /tmp/wordpress.tar.gz https://wordpress.org/latest.tar.gz
    - unless: test -f {{ directory_root }}/wp-config.php

extract_wordpress:
  cmd.run:
    - name: tar -xzf /tmp/wordpress.tar.gz --strip-components=1 -C {{ directory_root }}
    - require:
      - cmd: download_wordpress
    - unless: test -d {{ directory_root }}

wordpress_permissions:
  file.directory:
    - name: {{ directory_root }}
    - user: {{ directory_owner }}
    - group: {{ directory_group }}
    - recurse:
      - user
      - group
    - require:
      - cmd: extract_wordpress

create_wp_database:
  cmd.run:
    - name: mysql -e "CREATE DATABASE IF NOT EXISTS {{ wp_db_name }}; GRANT ALL ON {{ wp_db_name }}.* TO '{{ wp_db_user }}'@'localhost' IDENTIFIED BY '{{ wp_db_passwd }}'; FLUSH PRIVILEGES;"
wordpress_config:
  file.managed:
    - name: {{ directory_root }}/wp-config.php
    - contents: |
        <?php
        define('DB_NAME', '{{ wp_db_name }}');
        define('DB_USER', '{{ wp_db_user }}');
        define('DB_PASSWORD', '{{ wp_db_passwd }}');
        define('DB_HOST', 'localhost');
        define('DB_CHARSET', 'utf8');
        define('DB_COLLATE', '');
        $table_prefix = 'wp_';
        define('WP_DEBUG', false);
        if ( !defined('ABSPATH') )
            define('ABSPATH', dirname(__FILE__) . '/');
        require_once(ABSPATH . 'wp-settings.php');
    - require:
      - cmd: extract_wordpress
      - cmd: create_wp_database
{%- endif %}
