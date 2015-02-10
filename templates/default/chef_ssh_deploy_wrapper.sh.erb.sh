#!/bin/sh
exec ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i "/home/#{node[:base][:username]}/.ssh/id_rsa" "$@"