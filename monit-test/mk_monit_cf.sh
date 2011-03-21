#! /bin/ksh

# create monit config with correct paths


sed -e 's:\$DIR:'$(pwd)":" monit.cf.tmpl > monit.cf
# monit is rather strict about access to its config file
chmod go-rwx monit.cf

