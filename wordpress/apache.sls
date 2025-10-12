{% set os_family = grains['os_family'] %}
{% set os_name = grains['os'] %}

{% if os_family == 'Suse' %}
apache_install:
  pkg.installed:
    - name: apache2

apache_service:
  service.running:
    - name: apache2
    - enable: True
    - require:
      - pkg: apache_install

{% elif os_family == 'RedHat' %}
apache_install:
  pkg.installed:
    - name: httpd

apache_service:
  service.running:
    - name: httpd
    - enable: True
    - require:
      - pkg: apache_install

{% elif os_family == 'Debian' %}
apache_install:
  pkg.installed:
    - name: apache2

apache_service:
  service.running:
    - name: apache2
    - enable: True
    - require:
      - pkg: apache_install
{% endif %}

apache_vhost:
  file.managed:
    - name: {% if os_family == 'RedHat' %}/etc/httpd/conf.d/wordpress.conf{% else %}/etc/apache2/sites-available/wordpress.conf{% endif %}
    - contents: |
        <VirtualHost *:80>
            DocumentRoot /var/www/html/wordpress
            <Directory /var/www/html/wordpress>
                AllowOverride All
                Require all granted
            </Directory>
        </VirtualHost>
    - require:
      - pkg: apache_install

{% if os_family != 'RedHat' %}
enable_site:
  cmd.run:
    - name: a2ensite wordpress.conf && a2enmod rewrite
    - require:
      - file: apache_vhost
    - watch_in:
      - service: apache_service
{% endif %}