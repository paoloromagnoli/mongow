# Notes about mongodb configuration

# Enabling listening on all IP
# https://www.mongodb.com/docs/manual/reference/configuration-options/

$ sudo vi /etc/mongod.conf

net:
  port: 27017
  bindIp: 0.0.0.0

$ systemctl restart mongod

# Enabling authentication on MongoDB
# from https://medium.com/mongoaudit/how-to-enable-authentication-on-mongodb-b9e8a924efac

$ mongosh

test> use admin

db.createUser({user: "useradmin" , pwd: "mypassword", roles: [  "userAdminAnyDatabase","readWriteAnyDatabase" ]})

admin> db.createUser(
  {
    user: "useradmin",
    pwd: "mypassword",
    roles: [ { role: "userAdminAnyDatabase", db: "admin" } ]
  }
)

admin> exit

$ sudo vi /etc/mongod.conf

security:
    authorization: "enabled"

$ systemctl restart mongod

$ mongosh

test> use admin

admin> db.auth("useradmin", "mypassword")

# connection string
mongodb://host:27017/<database>

# configure backup
# configure cron based on https://www.hostinger.com/tutorials/cron-job?utm_campaign=Generic-Tutorials-DSA|NT:Se|LO:NL&utm_medium=ppc&gad_source=1&gclid=Cj0KCQjwjNS3BhChARIsAOxBM6qyZ-lVcc421nPwfBLSsAQFAjZZP3MWgBP9_s7BDxiTre_PV1wKMucaApkxEALw_wcB
# cronie from https://docs.rockylinux.org/guides/automation/cronie/

crontab -e

# every hour
0 * * * * /home/ec2-user/backup.sh

# every 6 hours
* */6 * * * /home/ec2-user/backup.sh