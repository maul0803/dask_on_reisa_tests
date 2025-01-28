# ./Launcher.sh P1 P2 P/NODE D1 D2 IT AN CPUSW PROGRAM


########################### DERIVATIVE
./Launcher.sh 2 2 2 1024 512 12 2 30 derivative;
./Launcher.sh 2 2 2 2048 1024 12 2 30 derivative;
./Launcher.sh 2 2 2 4096 2048 12 2 30 derivative;
./Launcher.sh 2 2 2 8192 4096 12 2 30 derivative;

# ########################### REDUCTION
./Launcher.sh 2 2 2 1024 512 25 2 30 reduction;
./Launcher.sh 2 2 2 2048 1024 25 2 30 reduction;
./Launcher.sh 2 2 2 4096 2048 25 2 30 reduction;
./Launcher.sh 2 2 2 8192 4096 25 2 30 reduction;