# ./Launcher.sh P1 P2 P/NODE D1 D2 IT AN WORKER/N THR/W PROGRAM

########################### DERIVATIVE
./Launcher.sh 2 2 2 8192 4096 12 2 30 1 derivative;
./Launcher.sh 2 2 2 8192 8192 12 2 30 1 derivative;
./Launcher.sh 2 4 2 8192 4096 12 4 30 1 derivative;
./Launcher.sh 2 4 2 8192 8192 12 4 30 1 derivative;
./Launcher.sh 4 4 2 8192 4096 12 8 30 1 derivative;
./Launcher.sh 4 4 2 8192 8192 12 8 30 1 derivative;

./Launcher.sh 8 16 32 256 512 12 2 30 1 derivative;
./Launcher.sh 8 16 32 4096 4096 12 2 30 1 derivative;
./Launcher.sh 32 16 32 256 512 12 8 30 1 derivative;
./Launcher.sh 32 16 32 4096 4096 12 8 30 1 derivative;


########################### REDUCTION
./Launcher.sh 2 2 2 8192 4096 25 2 30 1 reduction;
./Launcher.sh 2 2 2 8192 8192 25 2 30 1 reduction;
./Launcher.sh 2 4 2 8192 8192 25 4 30 1 reduction;
./Launcher.sh 2 4 2 8192 4096 25 4 30 1 reduction;
./Launcher.sh 4 4 2 8192 4096 25 8 30 1 reduction;
./Launcher.sh 4 4 2 8192 8192 25 8 30 1 reduction;

./Launcher.sh 8 16 32 256 512 25 2 30 1 reduction;
./Launcher.sh 8 16 32 4096 4096 25 2 30 1 reduction;
./Launcher.sh 32 16 32 256 512 25 8 30 1 reduction;
./Launcher.sh 32 16 32 4096 4096 25 8 30 1 reduction;