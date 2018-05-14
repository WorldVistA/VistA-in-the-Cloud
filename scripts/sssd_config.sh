#!/bin/bash

vm_group_name=$1
vm_name=$2

echo "Updating Linux SSSD Config"
echo "**Warning** This can take about 5 minutes"
az vm extension set --publisher Microsoft.Azure.Extensions --name CustomScript --version 2.0  --resource-group "${vm_group_name}" --vm-name "${vm_name}" --settings "{'commandToExecute':'echo -n \"[sssd]\ndomains = osehravic.onmicrosoft.com\nconfig_file_version = 2\nservices = nss, pam, ssh\n[pam]\n\n\n[domain/osehravic.onmicrosoft.com]\nad_domain = osehravic.onmicrosoft.com\nkrb5_realm = OSEHRAVIC.ONMICROSOFT.COM\nrealmd_tags = manages-system joined-with-samba\ncache_credentials = True\nid_provider = ad\nauth_provider = ad\nchpass_provider = ad\nldap_schema = ad\nkrb5_store_password_if_offline = True\ndefault_shell = /bin/bash\nldap_id_mapping = True\nldap_user_objectsid = objectSid\nldap_idmap_range_size = 2000000\nuse_fully_qualified_names = False\nfallback_homedir = /home/%u\naccess_provider = ad\ndyndns_update = True\ndyndns_refresh_interval = 43200\ndyndns_update_ptr = True\ndyndns_ttl = 3600\nauto_private_groups = True\n\" > /etc/sssd/sssd.conf && systemctl restart sssd'}" > /dev/null
echo "Getting id of VM Extension"
extension_id=$(az vm extension list -g ${vm_group_name} --vm-name ${vm_name} --query "[0].id" -otsv)
echo "Cleaning up Linux SSSD Extension"
az vm extension delete --ids $extension_id > /dev/null
