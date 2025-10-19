# Salt Wordpress

## States

Deploy directory ***wordpress*** in salt working directory, normally /srv/salt.

After setting pillars, use the command ***salt-call state.apply wordpress*** to deploy Wordpress application in the system.

This states where tested in:

- SUSE Linux Enterprise Server 15 SP 7
- OpenSUSE Leap 15
- Rocky Linux 9
- Oracle Linux 9
- Ubuntu 24 LTS

## SUSE Multi-Linux Manager Formula

Copy files inside ***formulas*** to /srv/formula_metadata/wordpress.

Enable and configure Formula inside SUSE Multi-Linux Manager WebUI.

