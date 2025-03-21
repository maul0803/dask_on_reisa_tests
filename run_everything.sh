#!/bin/bash
module load cesga/2020 python/3.9.9
module load cesga/2022 gcc/system ucx/1.11.2 gdrcopy/2.3 slurm/cesga gcccore/system hwloc/2.7.1 cuda/system ucx-cuda/1.11.2 openmpi/4.1.4
export PATH=$PATH:/home/ulc/cursos/curso341/.local/bin

START_DIR=$PWD

#cd E1/DEISA; "$START_DIR/exp.sh"; cd $START_DIR;
#cd E1/REISA; "$START_DIR/exp.sh"; cd $START_DIR;
#cd E1/REISA_ONE_ACTOR; "$START_DIR/exp.sh"; cd $START_DIR;
#cd E2/DASK_ON_REISA; "$START_DIR/exp.sh"; cd $START_DIR;
#cd E2/DASK_ON_REISA_ONE_ACTOR; "$START_DIR/exp.sh"; cd $START_DIR;

cd E4/DASK_ON_REISA_ONE_ACTOR; "$START_DIR/exp.sh"; cd $START_DIR;
cd E5/DASK_ON_REISA_ONE_ACTOR; "$START_DIR/exp.sh"; cd $START_DIR;