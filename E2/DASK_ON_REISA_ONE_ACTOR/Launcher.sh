#!/bin/bash

# Check if cluster_config.yml exists
CLUSTER_CONFIG_PATH="../../cluster_config.yml"
if [ ! -f $CLUSTER_CONFIG_PATH ]; then
  echo "Error: cluster_config.yml file not found!" >&2
  exit 1
fi

# Extract values from cluster_config.yml
PDI_PREFIX=$(grep "pdi_prefix" $CLUSTER_CONFIG_PATH | awk -F': ' '{print $2}' | tr -d ' ')
PARTITION=$(grep "partition" $CLUSTER_CONFIG_PATH | awk -F': ' '{print $2}' | tr -d ' ')
CORES_PER_NODE=$(grep "cores_per_node" $CLUSTER_CONFIG_PATH | awk -F': ' '{print $2}' | tr -d ' ')
RAM_RAW=$(grep "ram_per_node" $CLUSTER_CONFIG_PATH | awk -F': ' '{print $2}' | tr -d ' ')

# Validate extracted values
if [ -z "$PDI_PREFIX" ] || [ -z "$PARTITION" ] || [ -z "$CORES_PER_NODE" ] || [ -z "$RAM_RAW" ]; then
  echo "Error: Failed to retrieve values from cluster_config.yml!" >&2
  exit 1
fi

# Export PDI path
export PATH=${PDI_PREFIX}/bin:${PATH}

# Convert RAM_PER_NODE to MB based on its unit
if [[ "$RAM_RAW" == *G ]]; then
  RAM_PER_NODE=$(echo "$RAM_RAW" | tr -d 'G')  # Remove 'G'
  RAM_PER_NODE=$((RAM_PER_NODE * 1000))  # Convert to MB
elif [[ "$RAM_RAW" == *M ]]; then
  RAM_PER_NODE=$(echo "$RAM_RAW" | tr -d 'M')  # Already in MB
else
  echo "Error: Unknown memory unit in cluster_config.yml (expected G or M)" >&2
  exit 1
fi

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

# Compute memory per CPU (90% of total memory)
MEM_PER_CPU=$(echo "scale=0; ($RAM_PER_NODE * 0.9 / $CORES_PER_NODE)" | bc)

# Validate computed memory per CPU
if [ "$MEM_PER_CPU" -le 0 ]; then
  echo "Error: Invalid memory per CPU calculation!" >&2
  exit 1
fi

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
`which python` prescript.py $DATASIZE1 $DATASIZE2 $PARALLELISM1 $PARALLELISM2 $GENERATION $WORKER_NODES $MPI_PER_NODE $CORES_PER_NODE $WORKER_THREADING $SIMUNODES # Create config.yml

echo -e "$0 $1 $2 $3 $4 $5 $6 $7 $8 $9 ${10}" > rerun.sh

# RUNNING
echo -e "Executing $(sbatch --parsable --nodes=$NNODES --mincpus=${CORES_PER_NODE} --mem-per-cpu=${MEM_PER_CPU}M --partition ${PARTITION} --ntasks=$NPROC Script.sh $SIMUNODES $MPI_PER_NODE $CORES_PER_NODE $9 ${10}) in $PWD    " >> ../../../../jobs.log
cd $MAIN_DIR