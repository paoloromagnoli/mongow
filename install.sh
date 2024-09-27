#!/bin/bash
# install MongoDB on amazon linux 2023
# referenced from https://www.mongodb.com/docs/manual/tutorial/install-mongodb-on-amazon/

# configure the package management system
cat <<EOF >> /etc/yum.repos.d/mongodb-org-7.0.repo
[mongodb-org-7.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/amazon/2023/mongodb-org/7.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://pgp.mongodb.com/server-7.0.asc
EOF

# install mongodb-mongosh-shared-openssl3
# this works with OpenSSL v3 as per https://www.mongodb.com/community/forums/t/openssl-error-when-starting-mongosh/243323
sudo yum install -y mongodb-mongosh-shared-openssl3

# install the latest stable version of mongo
# this will not install mongodb-mongosh as it doesn't support OpenSSL v3 which is boundled wtih  Amazon Linux 2023
sudo yum install -y mongodb-org

# start & enable mongo
sudo systemctl start mongod
sudo systemctl enable mongod

# install cronie
sudo yum install -y cronie

# start & enable cronie
sudo systemctl start crond
sudo systemctl enable crond