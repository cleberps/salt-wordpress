{%- set p = salt['pillar.get']('suma_wordpress')  %}
{%- if p is defined and
    p.apache is defined %}
{%- set apache = p.apache %}
{%- set os_family         = salt['grains.get']('os_family', None) %}
{%- set directory_root    = apache["directory_root"] %}
{%- if os_family == 'Suse' %}
{%- set apache_pkg_name = "apache2" %}
{%- set apache_svc_name = "apache2.service" %}
{%- set apache_cfg_name = "/etc/httpd/conf.d/wordpress.conf" %}
{%- elif os_family == 'RedHat' %}
{%- set apache_pkg_name = "httpd" %}
{%- set apache_svc_name = "httpd.service" %}
{%- set apache_cfg_name = "/etc/httpd/conf.d/wordpress.conf" %}
{%- elif os_family == 'Debian' %}
{%- set apache_pkg_name = "apache2" %}
{%- set apache_svc_name = "apache2.service" %}
{%- set apache_cfg_name = "/etc/apache2/sites-available/wordpress.conf" %}
{%- endif %}

apache_install:
  pkg.installed:
    - name: {{ apache_pkg_name }}

apache_service:
  service.running:
    - name: {{ apache_svc_name }}
    - enable: True
    - require:
      - pkg: {{ apache_pkg_name }}

apache_vhost:
  file.managed:
    - name: {{ apache_cfg_name }}
    - contents: |
        <VirtualHost *:80>
            DocumentRoot {{ directory_root }}
            <Directory {{ directory_root }}>
                AllowOverride All
                Require all granted
            </Directory>
        </VirtualHost>
    - require:
      - pkg: {{ apache_pkg_name }}

{%- if os_family == 'Debian' %}
enable_site:
  cmd.run:
    - name: a2ensite wordpress.conf && a2enmod rewrite
    - require:
      - file: {{ apache_cfg_name }}
    - watch_in:
      - service: {{ apache_svc_name }}
{%- endif %}
{%- endif %}
