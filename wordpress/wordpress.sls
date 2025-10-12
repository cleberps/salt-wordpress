{% set wp_db = pillar.get('wordpress:db_name', 'wordpress') %}
{% set wp_user = pillar.get('wordpress:db_user', 'wpuser') %}
{% set wp_pass = pillar.get('wordpress:db_pass', 'wppass') %}

php_install:
  pkg.installed:
    - pkgs:
      {% if grains['os_family'] == 'RedHat' %}
      - php
      - php-mysql
      - php-gd
      {% elif grains['os_family'] == 'Debian' %}
      - php
      - php-mysql
      - php-gd
      - libapache2-mod-php
      {% else %}
      - php
      - php-mysql
      - php-gd
      {% endif %}

download_wordpress:
  cmd.run:
    - name: wget -O /tmp/wordpress.tar.gz https://wordpress.org/latest.tar.gz
    - unless: test -f /var/www/html/wordpress/wp-config.php

extract_wordpress:
  cmd.run:
    - name: tar -xzf /tmp/wordpress.tar.gz -C /var/www/html/
    - require:
      - cmd: download_wordpress
    - unless: test -d /var/www/html/wordpress

wordpress_permissions:
  file.directory:
    - name: /var/www/html/wordpress
    - user: www-data
    - group: www-data
    - recurse:
      - user
      - group
    - require:
      - cmd: extract_wordpress

create_wp_database:
  cmd.run:
    - name: mysql -e "CREATE DATABASE IF NOT EXISTS {{ wp_db }}; GRANT ALL ON {{ wp_db }}.* TO '{{ wp_user }}'@'localhost' IDENTIFIED BY '{{ wp_pass }}'; FLUSH PRIVILEGES;"

wordpress_config:
  file.managed:
    - name: /var/www/html/wordpress/wp-config.php
    - contents: |
        <?php
        define('DB_NAME', '{{ wp_db }}');
        define('DB_USER', '{{ wp_user }}');
        define('DB_PASSWORD', '{{ wp_pass }}');
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