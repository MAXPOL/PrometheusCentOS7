#!/bin/bash

yum remove -y firewalld

yum install iptables-services -y
systemctl start iptables
systemctl enable iptables
