#!/bin/bash

stop(){
	printf "node$1: **********************************************"
	ssh root@node$1 "crm cluster stop"
}

init(){
	printf "node$1: **********************************************"
	ssh root@node$1 "crm cluster init -u -n cluster$1 -y"
}

join(){
	master=$1
	slave=$2
	printf "node$slave: **********************************************"
	ssh root@node$slave "crm cluster join -c alex-test-node0$master -y"
}

status(){
	printf "node$1: **********************************************"
	ssh root@node$1 "crm status"
}

create_stateful_resource() {
	printf "node$1: **********************************************"
	ssh root@node$1 "crm configure primitive stateful-1 ocf:pacemaker:Stateful op monitor interval=10s op monitor interval=5s role=Master"
	ssh root@node$1 "crm configure clone promotable-1 stateful-1 meta promotable=true"
}

init_qdevice(){
	printf "node$1: **********************************************"
	ssh root@node$1 "crm cluster init qdevice --qnetd-hostname=alex-test-qdevice --qdevice-heuristics=/etc/corosync/qdevice/check_master.sh -y" &
}

maxnode=6

all_stop(){
	for node in $(seq 1 1 $maxnode); do 
		stop $node
	done
}

all_init(){
	for node in $(seq 1 2 $maxnode); do 
		init $node
	done
}

all_join() {
	for node in $(seq 2 2 $maxnode); do
		master=$(expr $node - 1)
		join $master $node
	done
}

all_status(){
	for node in $(seq 1 $maxnode); do
		status $node
	done
}

all_create_resource(){
	for node in $(seq 1 2 $maxnode); do 
		create_stateful_resource $node
	done
}

all_init_qdevice(){
	for node in $(seq 1 2 $maxnode); do 
		init_qdevice $node
	done
}

case $1 in
  stop)
    all_stop
    ;;

  init)
    all_init
    ;;

  join)
    all_join
    ;;

  res)
    all_create_resource
    ;;

  qdevice)
    all_init_qdevice
    ;;

  status)
    all_status
    ;;

  all)
    all_stop && \
    all_init && \
    all_join && \
    all_create_resource && \
    all_status && \
    all_init_qdevice
    ;;


  *)
    echo "Wrong artument. Printing status"
    all_status
    ;;
esac
