{%- set p = salt['pillar.get']('suma_wordpress')  %}
{%- if p is defined %}
include:
  - .database
  - .apache
  - .wordpress
{%- endif %}
