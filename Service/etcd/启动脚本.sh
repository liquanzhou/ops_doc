#!/bin/sh

ETCD_INITIAL_CLUSTER="infra0=http://10.10.10.117:2380,infra1=http://10.10.10.118:2380,infra2=http://10.10.10.119:2380"
ETCD_INITIAL_CLUSTER_STATE=new

nohup ./etcd -name infra1 -initial-advertise-peer-urls http://10.10.10.118:2380 \
  -listen-peer-urls http://10.10.10.118:2380 \
  -listen-client-urls http://10.10.10.118:2379,http://127.0.0.1:2379 \
  -advertise-client-urls http://10.10.10.118:2379 \
  -initial-cluster-token etcd-cluster-1 \
  -initial-cluster infra0=http://10.10.10.117:2380,infra1=http://10.10.10.118:2380,infra2=http://10.10.10.119:2380 \
  -initial-cluster-state new  &