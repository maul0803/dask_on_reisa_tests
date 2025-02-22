#!/bin/bash
#SBATCH --time=00:20:00
#SBATCH -o deisa.log
#SBATCH --mem-per-cpu=4GB
#SBATCH --exclusive
module load gcc/11.2.0/gcc-4.8.5 openmpi/4.1.1/gcc-11.2.0;

echo -e "Slurm job started at $(date +%d/%m/%Y_%X)\n"

# Configure the different parameters
SCHEFILE="scheduler.json";
NNODES=$(( $SLURM_NNODES - 1 ))
SIMUNODES=$(($1/$2))
WORKERNODES=$(($NNODES - $SIMUNODES))
NPROC=$1
NWORKER=$(( $WORKERNODES * $3 ))
WORKERS_PER_NODE=$3
THREADS=$4
echo "NNODES = $NNODES"
echo "SIMUNODES = $SIMUNODES"
echo "WORKERNODES = $WORKERNODES"
echo "NPROC = $NPROC"
echo "NWORKER = $NWORKER"
# Launching the scheduler
srun -N 1 -n 1 -c 1 --relative 0 dask-scheduler --interface ib0 --protocol tcp --scheduler-file=$SCHEFILE 1>>logs/scheduler.log 2>>logs/scheduler.log &
# Wait for the SCHEFILE to be created
while ! [ -f $SCHEFILE ]; do
    sleep 3
    echo -n .
done
# Connect the client to the Dask scheduler
srun -N 1 -n 1 -c 1 --relative 0 `which python` -m trace -l -g $5.py &
client_pid=$!

# Launch Dask workers in the rest of the allocated nodes
srun -N $WORKERNODES -n $NWORKER -c $THREADS --relative 1 dask-worker --local-directory $TMPDIR --scheduler-file=$SCHEFILE 1>>logs/worker.log 2>>logs/worker.log &

# Launch the simulation code
REL=$(( $WORKERNODES + 1 ))
srun -N $SIMUNODES -n $1 -c 1 --ntasks-per-node=$2 --relative $REL ./simulation &
sim_pid=$!
wait $sim_pid
# Wait for the client process to be finished
wait $client_pid

sed -i '/^filename:/d' deisa.log
sleep 3
echo -e "HTML_ANALYTICS_TIME:      $(grep -o "Duration:.................." dask-report.html | awk {'print $2'})" >> deisa.log
echo -e "HTML_TRANSFER_TIME:       $(grep -o "transfer time:.................." dask-report.html | awk {'print $3'})" >> deisa.log
echo -e "HTML_DESERIALIZE_TIME:    $(grep -o "deserialize time:.................." dask-report.html | awk {'print $3'})" >> deisa.log
echo -e "HTML_COMPUTE_TIME:        $(grep -o "compute time:.................." dask-report.html | awk {'print $3'})" >> deisa.log

echo -e "\nSlurm job finished at $(date +%d/%m/%Y_%X)"
