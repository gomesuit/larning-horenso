#!/bin/bash
set -e

# install horenso
wget https://github.com/Songmu/horenso/releases/download/v0.0.2/horenso_linux_amd64.tar.gz
tar zxfv horenso_linux_amd64.tar.gz
cp horenso_linux_amd64/horenso /usr/bin/

yum install -y perl-JSON-PP


