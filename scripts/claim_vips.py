# Copyright (c) 2020, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.


import sys, oci, logging, os

def assign_to_different_vnic(private_ip_id, vnic_id):    
    logging.info("-------------------------------------------------------------------------------------------")
    logging.info("Private IP before being moved to the backup instance:")
    logging.info("-------------------------------------------------------------------------------------------")
    logging.info(network.get_private_ip(private_ip_id).data)
    logging.info("-------------------------------------------------------------------------------------------")
    update_private_ip_details = oci.core.models.UpdatePrivateIpDetails(vnic_id=vnic_id)
    logging.info("-------------------------------------------------------------------------------------------")
    logging.info("Updating the Private IP with the following values")
    logging.info("-------------------------------------------------------------------------------------------")
    logging.info(update_private_ip_details)
    logging.info("-------------------------------------------------------------------------------------------")
    network.update_private_ip(private_ip_id, update_private_ip_details)
    logging.info("-------------------------------------------------------------------------------------------")
    logging.info("Private IP after being moved to the backup instance:")
    logging.info("-------------------------------------------------------------------------------------------")
    logging.info(network.get_private_ip(private_ip_id).data)
    logging.info("-------------------------------------------------------------------------------------------")
    
    

if __name__ == '__main__':
    #config file authentication
    #config = oci.config.from_file()
    #network = oci.core.VirtualNetworkClient(config)
    #instance principal authentication
    signer = oci.auth.signers.InstancePrincipalsSecurityTokenSigner()
    network = oci.core.VirtualNetworkClient(config={}, signer=signer)
    
    logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(message)s ')
    logging.info("-------------------------------------------------------------------------------------------")
    logging.info("Claim Public and Private VIPs")
    logging.info("-------------------------------------------------------------------------------------------")

    new_vnic_id = sys.argv[1]
    privateip_id = sys.argv[2]
    assign_to_different_vnic(privateip_id, new_vnic_id)

    
