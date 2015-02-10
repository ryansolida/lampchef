#!/bin/sh
exec ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i "/home/#{node['myapp']['user']}/.ssh/id_rsa" "$@"