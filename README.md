# Openstack_Project

1. This project involves the deployment and operation of a service within an OpenStack Cloud, integrating elements of network design, service deployment, and automation. The solution operates in three distinct phases: deployment, operations, and cleanup. During deployment, essential network infrastructure and nodes are created, tagged for easy identification, and configured to ensure secure communication. The operations phase involves continuous monitoring of node availability and dynamically adjusting resources to maintain system integrity. Finally, the cleanup phase ensures the release of all allocated resources, promoting efficient resource management.

First, we need to generate an SSH key by executing either "ssh-keygen" or "ssh-keygen -t rsa -b 4096"(cat ~/.ssh/id_rsa.pub). The second step involves creating an "openrc" file within OpenStack users, copying and pasting its contents into Ubuntu,Before pasting, simply update the password you created for the openrc file and put that password in the openrc file and running the following commands for proper configuration:

#chmod 600 openrc        (to set permissions)\
#source openrc           (to source the file)\
#openstack token issue   (to establish connection between Ubuntu and OpenStack)\

## To execute the code, follow these commands:

a. Set executable permissions for the "install" script:\
  chmod +x install\
  ./install openrc nso ssh\
b. Set executable permissions for the "operate" script:\
   chmod +x operate\
   ./operate openrc nso ssh\
c. Lastly, ensure executable permissions for the "cleanup" script:\
   chmod +x cleanup\
   ./cleanup openrc nso ssh




  ###command to see the opnestack servers -- openstack server list\
  ###command to pause the server          -- openstack server pause $serve_rname\
   
#### These commands facilitate the deployment, operation, and cleanup of the service within the OpenStack Cloud environment efficiently.


2. Report: The report provides a thorough description of the design, performance evaluation, and scalability factors. It is divided into three sections: a description of the design, performance evaluation using Apache Benchmark, and reasons for managing the system on a big scale.
3. command to perform the ab test ---- ( ab -n 1 -c 1 http://HAproxy_fip:port(5000)/ ) (here "n" is no of users/requests per sec and "c" is concurrency)


#### prometheus and grafana are two powerful tools commonly used together for monitoring and visualization in modern IT environments. They form a robust combination for observing, alerting, and visualizing metrics and logs from various systems and applications.
1.prometheus  Bastion_fip:9090\
2.Grafana     Bastion_fip:3000\ (Next, Bastion_fip must be set up and a dashboard needs to be created before the metrics can be seen. )
