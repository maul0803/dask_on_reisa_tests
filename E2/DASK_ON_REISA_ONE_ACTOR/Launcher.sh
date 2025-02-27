#!/bin/bash

PDI_PREFIX=${HOME}/opt/pdi_py39
export PATH=${PDI_PREFIX}/bin:${PATH}

#PARTITION=cpu_short    # Ruche
PARTITION=short         # FT3

MAIN_DIR=$PWD

# MPI VALUES
PARALLELISM1=$1 # MPI nodes axis x
PARALLELISM2=$2 # MPI nodes axis y
MPI_PER_NODE=$3 # MPI processes per simulation node

# DATASIZE
DATASIZE1=$(($4*$PARALLELISM1)) # Number of elements axis x
DATASIZE2=$(($5*$PARALLELISM2)) # Number of elements axis y

# STEPS
GENERATION=$6 # Number of iterations on the simulation

# ANALYTICS HARDWARE
WORKER_NODES=$7 # DEISA uses (MPI_PROCESSES/4) worker nodes  with 48 threads each one
CPUS_PER_WORKER=$8 # 24 # Parallelism on each worker

# AUXILIAR VALUES
SIMUNODES=$(($PARALLELISM2 * $PARALLELISM1 / $MPI_PER_NODE)) # NUMBER OF SIMULATION NODES
NNODES=$(($WORKER_NODES + $SIMUNODES + 1)) # WORKERS + HEAD + SIMULATION (CLIENT WILL BE WITHIN THE HEAD NODE)
NPROC=$(($PARALLELISM2 * $PARALLELISM1 + $NNODES + 1)) # NUMBER OF DEPLOYED TASKS (MPI + ALL RAY INSTANCES + CLIENT)
MPI_TASKS=$(($PARALLELISM2 * $PARALLELISM1)) # NUMBER OF DEPLOYED TASKS (MPI + ALL RAY INSTANCES + CLIENT)
GLOBAL_SIZE=$(($DATASIZE1 * $DATASIZE2 * 8 / 1000000)) # NUMBER OF DEPLOYED TASKS (MPI + ALL RAY INSTANCES + CLIENT)
LOCAL_SIZE=$(($GLOBAL_SIZE / $MPI_TASKS)) # NUMBER OF DEPLOYED TASKS (MPI + ALL RAY INSTANCES + CLIENT)

# MANAGING FILES
date=$(date +%Y-%m-%d_%H-%M-%S)
OUTPUT=${9}/P${MPI_TASKS}-SN${SIMUNODES}-LS${LOCAL_SIZE}-GS${GLOBAL_SIZE}-I${GENERATION}-AN${WORKER_NODES}-D${date}
mkdir -p $OUTPUT
cp simulation.yml prescript.py $9.py reisa.py simulation.c CMakeLists.txt Script.sh $OUTPUT
cd $OUTPUT

# COMPILING
(CC=gcc CXX=g++ pdirun cmake .) > /dev/null 2>&1
pdirun make -B simulation > /dev/null 2>&1
`which python` prescript.py $DATASIZE1 $DATASIZE2 $PARALLELISM1 $PARALLELISM2 $GENERATION $WORKER_NODES $MPI_PER_NODE $CPUS_PER_WORKER $WORKER_THREADING $SIMUNODES # Create config.yml

echo -e "$0 $1 $2 $3 $4 $5 $6 $7 $8 $9 ${10}" > rerun.sh

# RUNNING
echo -e "Executing $(sbatch --parsable -N $NNODES --mincpus=40 --partition $PARTITION --ntasks=$NPROC Script.sh $SIMUNODES $MPI_PER_NODE $CPUS_PER_WORKER $9 ${10}) in $MAIN_DIR/$OUTPUT/" >> ../../../../jobs.log
cd $MAIN_DIR