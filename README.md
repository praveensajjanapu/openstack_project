# Openstack_Project

This project involves the deployment and operation of a service within an OpenStack Cloud, integrating elements of network design, service deployment, and automation. The solution operates in three distinct phases: deployment, operations, and cleanup. During deployment, essential network infrastructure and nodes are created, tagged for easy identification, and configured to ensure secure communication. The operations phase involves continuous monitoring of node availability and dynamically adjusting resources to maintain system integrity. Finally, the cleanup phase ensures the release of all allocated resources, promoting efficient resource management.

first we need to create ssh
# ssh-keygen or ssh-keygen -t rsa -b 4096

second step is to create openrc file in openstack users and copy it in ubuntu 
# chmod 600 openrc
# source openrc
# openstack token issue
