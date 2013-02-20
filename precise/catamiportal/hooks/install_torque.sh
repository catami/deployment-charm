#!/bin/bash

NUM_CPUS=4

apt-get install -y libtorque2 torque-common torque-mom torque-pam torque-scheduler torque-server

#==================================================
# SET UP THE SAME GROUP THAT CATAMI BELONGS TO
# ON EPIC AND THE CURRENT USER
#==================================================
sudo groupadd partner464
sudo usermod -a -G partner464 `whoami`

#==================================================
# KILL PBS SO WE CAN CHANGE SETTINGS
#==================================================
killall pbs_mom
killall pbs_sched
killall pbs_server

echo "SERVERHOST $HOSTNAME" > /var/spool/torque/torque.cfg
echo "$HOSTNAME np ${NUM_CPUS}" > /var/spool/torque/server_priv/nodes
echo "\$pbs_server $HOSTNAME" > /var/spool/torque/mom_priv/config
echo "$HOSTNAME" > /etc/torque/server_name

#bug fix
echo "altering /etc/hosts for bug fix"
sed -i "s/127.0.0.1   localhost/127.0.0.1   localhost $HOSTNAME/g" /etc/hosts

#==================================================
# CREATE A QUEUE THE SAME NAME AS EPIC
#==================================================

pbs_server
pbs_sched
pbs_mom

qmgr -c "create queue routequeue"
qmgr -c "set queue routequeue queue_type = Execution"
qmgr -c "set queue routequeue max_running = 6"
qmgr -c "set queue routequeue resources_max.ncpus = ${NUM_CPUS}"
qmgr -c "set queue routequeue resources_max.nodes = 1"
qmgr -c "set queue routequeue resources_default.ncpus = 1"
qmgr -c "set queue routequeue resources_default.neednodes = 1:ppn=1"
qmgr -c "set queue routequeue resources_default.walltime = 24:00:00"
qmgr -c "set queue routequeue max_user_run = 6"
qmgr -c "set queue routequeue enabled = True"
qmgr -c "set queue routequeue started = True"
qmgr -c "set server default_queue = routequeue"
qmgr -c "set server scheduling = True"

echo pbsnodes -a
echo qstat -Q
