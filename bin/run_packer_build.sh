#!/usr/bin/env sh
source aws_conf.sh
packer build consul/packer.json
