#!/bin/bash

DIR=$PWD

### prescript.py  is used to create the configuration file that is shared betwwen the simulation and the Dask cluster
# sys.argv[1] = global_size.height
# sys.argv[2] = global_size.width
# sys.argv[3] = parallelism.height
# sys.argv[4] = parallelism.width
# sys.argv[5] = generation 
# sys.argv[6] = nworkers


PARALLELISM1=$1
PARALLELISM2=$2
MPI_PER_NODE=$3

DATASIZE1=$(($4*$PARALLELISM1))
DATASIZE2=$(($5*$PARALLELISM2))

GENERATION=$6
WORKER_NODES=$7
NWORKER=$8
WORKER_THREADING=$9
PR=${10}

MPI_TASKS=$(($PARALLELISM2 * $PARALLELISM1)) # NUMBER OF DEPLOYED TASKS (MPI + ALL RAY INSTANCES + CLIENT)
GLOBAL_SIZE=$(($DATASIZE1 * $DATASIZE2 * 8 / 1000000)) # NUMBER OF DEPLOYED TASKS (MPI + ALL RAY INSTANCES + CLIENT)
LOCAL_SIZE=$(($GLOBAL_SIZE / $MPI_TASKS)) # NUMBER OF DEPLOYED TASKS (MPI + ALL RAY INSTANCES + CLIENT)

NNODESDASK=$WORKER_NODES
NNODESSIMU=$(($PARALLELISM2 * $PARALLELISM1 / $MPI_PER_NODE)) #2 procs per node
NNODES=$(($NNODESDASK + $NNODESSIMU + 1))
date=$(date +%Y-%m-%d_%X)
WORKSPACE=$PR/P$MPI_TASKS-SN$NNODESSIMU-LS$LOCAL_SIZE-GS$GLOBAL_SIZE-I$GENERATION-AN$WORKER_NODES-W$NWORKER-D$date
mkdir -p $WORKSPACE
cp simulation.yml dask_interface.py prescript.py $PR.py simulation.c CMakeLists.txt Script.sh $WORKSPACE
cd $WORKSPACE

echo -e "$0 $1 $2 $3 $4 $5 $6 $7 $8 $9 ${10}" > rerun.sh
mkdir logs
(CC=gcc CXX=g++ cmake .) > /dev/null 2>&1
make -B simulation > /dev/null 2>&1
echo -e "Running in $WORKSPACE"
`which python` prescript.py $DATASIZE1 $DATASIZE2 $PARALLELISM1 $PARALLELISM2 $GENERATION $(($NWORKER*$WORKER_NODES))

TASKS=$(($MPI_TASKS + $NWORKER*$WORKER_NODES + 2))

echo -e "Executing $(sbatch --parsable -N $NNODES -n $(($MPI_TASKS + $WORKER_NODES*$NWORKER + 2)) --mincpus=40 -c $WORKER_THREADING Script.sh $(($PARALLELISM1*$PARALLELISM2)) $MPI_PER_NODE $8 $9 $PR) in $DIR/$WORKSPACE/" >> ../../../../jobs.log


cd $DIR