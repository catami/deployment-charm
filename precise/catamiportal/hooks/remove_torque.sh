#!/bin/bash

killall pbs_mom
killall pbs_sched
killall pbs_server

sudo apt-get remove -y --purge libtorque2 torque-common torque-mom torque-pam torque-scheduler torque-server

# make sure the config files are gone too
rm -r /var/spool/torque

echo 'done'