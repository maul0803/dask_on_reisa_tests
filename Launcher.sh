#!/bin/bash

# spack load pdiplugin-pycall@1.6.0 pdiplugin-mpi@1.6.0;

PDI_PREFIX=${HOME}/opt/pdi_py39
export PATH=${PDI_PREFIX}/bin:${PATH}

#PARTITION=cpu_short    # Ruche
PARTITION=short         # FT3

MAIN_DIR=$PWD

GR='\033[0;32m'
BL='\033[0;34m'
NC='\033[0m' # No Color

# CHECKING SOFTWARE
echo -n -e "${BL}PDI"   
echo -e "${GR} `which pdirun`${NC}"
echo -n -e "${BL}MPI"   
echo -e "${GR} `which mpirun`${NC}"
echo -n -e "${BL}PYTHON"
echo -e "${GR} `which python`${NC}"
echo -n -e "${BL}RAY"   
echo -e "${GR} `which ray`${NC}"
echo -e "Running in $MAIN_DIR\n"

# COMPILING
(CC=gcc CXX=g++ pdirun cmake .) > /dev/null 2>&1
pdirun make -B simulation

# INPUT PARAMETERS
PARALLELISM1=$1   # MPI nodes for X axis
PARALLELISM2=$2   # MPI nodes for Y axis
MPI_PER_NODE=$3   # MPI processes per node
DATASIZE1=$(($4*$PARALLELISM1)) # Data size for X axis
DATASIZE2=$(($5*$PARALLELISM2)) # Data size for Y axis
GENERATION=$6     # Number of simulation iterations
WORKER_NODES=$7   # Number of analytics worker nodes
CPUS_PER_WORKER=$8 # CPUs per worker
PROGRAM=$9        # Program type (e.g., derivative, reduction)
OUTPUT_DIR=${10}  # Output directory (base path)

# AUXILIARY CALCULATIONS
SIMUNODES=$(($PARALLELISM2 * $PARALLELISM1 / $MPI_PER_NODE)) # Number of simulation nodes
NNODES=$(($WORKER_NODES + $SIMUNODES + 1)) # Workers + head + simulation
NPROC=$(($PARALLELISM2 * $PARALLELISM1 + $NNODES + 1)) # Total number of tasks deployed
MPI_TASKS=$(($PARALLELISM2 * $PARALLELISM1)) # Number of MPI tasks
GLOBAL_SIZE=$(($DATASIZE1 * $DATASIZE2 * 8 / 1000000)) # Global size in MB
LOCAL_SIZE=$(($GLOBAL_SIZE / $MPI_TASKS)) # Local size in MB

# MANAGING FILES
date=$(date +%Y-%m-%d_%H-%M-%S)
OUTPUT=$OUTPUT_DIR/P${PARALLELISM1}x${PARALLELISM2}-SN${SIMUNODES}-LS${LOCAL_SIZE}-GS${GLOBAL_SIZE}-I${GENERATION}-AN${WORKER_NODES}-${PROGRAM}-${date}
mkdir -p $OUTPUT
mkdir logs 2>/dev/null
touch logs/jobs.log

# Copy necessary files for reproducibility
cp *.yml *.py simulation Script.sh simulation.c CMakeLists.txt reisa.py $OUTPUT

# Save the relaunch command in rerun.sh
echo -e "$0 $1 $2 $3 $4 $5 $6 $7 $8 $9 ${10}" > $OUTPUT/rerun.sh
chmod +x $OUTPUT/rerun.sh

# RUNNING
cd $OUTPUT
echo -e "Executing sbatch --parsable -N $NNODES --mincpus=40 --partition ${PARTITION} --ntasks=$NPROC Script.sh $SIMUNODES $MPI_PER_NODE $CPUS_PER_WORKER $OUTPUT"
sbatch --parsable -N $NNODES --mincpus=40 --partition ${PARTITION} --ntasks=$NPROC Script.sh $SIMUNODES $MPI_PER_NODE $CPUS_PER_WORKER $OUTPUT >> $MAIN_DIR/logs/jobs.log
cd $MAIN_DIR
