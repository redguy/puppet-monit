#! /bin/ksh

# fail when anything fails
set -e



# compile simple testing daemons

gcc -o DAEMON1 daemon.c
cp DAEMON1 DAEMON2

rnd() {
  if [ $RANDOM -ge 16384 ] ; then
    echo "running";
  else
    echo "stopped"
  fi
}


while true ; do
  state1=$(rnd)
  state2=$(rnd)
  echo $state1 $state2
  cat > monit.pp <<EOT
service { 'DAEMON1':
    ensure => '${state1}',
    provider => "monit"
}
service { 'DAEMON2':
    ensure => '${state2}',
    provider => "monit"
}
EOT
  if ! RUBYLIB=../lib ../bin/puppet apply monit.pp  ; then
    if [ $? -eq 4 ] ; then
      echo puppet failed.
      exit 2
    fi
  fi

  actual1=$(pgrep DAEMON1 || true)
  actual2=$(pgrep DAEMON2 || true)

  if [ $state1 = "running" -a -z "$actual1" ] ; then
    echo 1 should be running.
    exit 1
  fi

  if [ $state2 = "running" -a -z "$actual2" ] ; then
    echo 2 should be running.
    exit 1
  fi

  if [ $state1 = "stopped" -a -n "$actual1" ] ; then
    echo 1 should NOT be running.
    exit 1
  fi

  if [ $state2 = "stopped" -a -n "$actual2" ] ; then
    echo 2 should NOT be running.
    exit 1
  fi
done

  
