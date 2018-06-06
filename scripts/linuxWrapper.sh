#!/bin/bash
org=$1
ad_password=$2
domain=$3
upper_domain=$($3 | tr [a-z] [A-Z])

# ssh_config
perl -pi -e 's/^#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config && perl -pi -e 's/^PasswordAuthentication no/#PasswordAuthentication no/g' /etc/ssh/sshd_config && perl -pi -e 's/^GSSAPICleanupCredentials no/GSSAPICleanupCredentials yes/g' /etc/ssh/sshd_config && perl -pi -e 's/^#KerberosAuthentication no/KerberosAuthentication yes/g' /etc/ssh/sshd_config && perl -pi -e 's/^#KerberosOrLocalPasswd yes/KerberosOrLocalPasswd yes/g' /etc/ssh/sshd_config && perl -pi -e 's/^#KerberosTicketCleanup yes/KerberosTicketCleanup yes/g' /etc/ssh/sshd_config && perl -pi -e 's/^#KerberosGetAFSToken no/KerberosGetAFSToken yes/g' /etc/ssh/sshd_config && perl -pi -e 's/^#KerberosUseKuserok yes/KerberosUseKuserok yes/g' /etc/ssh/sshd_config && systemctl restart sshd

# joinLinuxToDomain
yum install -y realmd sssd oddjob oddjob-mkhomedir adcli samba-common samba-common-tools ntpdate ntp && echo "$ad_password" | realm join --user=VITCAdmin --automatic-id-mapping=no --computer-ou="OU=Computers,OU=$org,OU=VITC-Machines" $domain

# sssd_config
echo -n "[sssd]\ndomains = $domain\nconfig_file_version = 2\nservices = nss, pam, ssh\n[pam]\n\n\n[domain/$domain]\nad_domain = $domain\nkrb5_realm = $upper_domain\nrealmd_tags = manages-system joined-with-samba\ncache_credentials = True\nid_provider = ad\nauth_provider = ad\nchpass_provider = ad\nldap_schema = ad\nkrb5_store_password_if_offline = True\ndefault_shell = /bin/bash\nldap_id_mapping = True\nldap_user_objectsid = objectSid\nldap_idmap_range_size = 2000000\nuse_fully_qualified_names = False\nfallback_homedir = /home/%u\naccess_provider = ad\ndyndns_update = True\ndyndns_refresh_interval = 43200\ndyndns_update_ptr = True\ndyndns_ttl = 3600\nauto_private_groups = True\n" > /etc/sssd/sssd.conf && systemctl restart sssd

# config_linux
yum install -y yum-utils device-mapper-persistent-data lvm2 git
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce
mkdir -p /mnt/resource/docker /etc/docker
echo '{"data-root": "/mnt/resource/docker"}' > /etc/docker/daemon.json
systemctl start docker
cd /mnt/resource
docker pull osehra/osehravista
docker run -p 9430:9430 -p 8001:8001 -p9080:9080 -p2222:22 -p57772:57772 -d -P --name=cache osehra/osehravista