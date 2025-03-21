# ./Launcher.sh P1 P2 P/NODE D1 D2 IT AN CPUSW PROGRAM


########################### DERIVATIVE
./Launcher.sh 2 2 2 8192 4096 10 2 30 derivative;
./Launcher.sh 2 2 2 8192 8192 10 2 30 derivative;

./Launcher.sh 2 4 2 8192 4096 10 4 30 derivative;
./Launcher.sh 2 4 2 8192 8192 10 4 30 derivative;

./Launcher.sh 4 4 2 8192 4096 10 8 30 derivative;
./Launcher.sh 4 4 2 8192 8192 10 8 30 derivative;

./Launcher.sh 8 16 32 256 512 10 2 30 derivative;
./Launcher.sh 8 16 32 4096 4096 10 2 30 derivative;

./Launcher.sh 32 16 32 256 512 10 8 30 derivative;
./Launcher.sh 32 16 32 4096 4096 10 8 30 derivative;

#./Launcher.sh 8 16 32 4096 4096 10 2 30 derivative 2;
#./Launcher.sh 8 16 32 4096 4096 10 2 30 derivative 4;
#./Launcher.sh 32 16 32 4096 4096 10 8 30 derivative 2;
#./Launcher.sh 32 16 32 4096 4096 10 8 30 derivative 4;

# ########################### REDUCTION
./Launcher.sh 2 2 2 8192 4096 20 2 30 reduction;
./Launcher.sh 2 2 2 8192 8192 20 2 30 reduction;

./Launcher.sh 2 4 2 8192 4096 20 4 30 reduction;
./Launcher.sh 2 4 2 8192 8192 20 4 30 reduction;

./Launcher.sh 4 4 2 8192 4096 20 8 30 reduction;
./Launcher.sh 4 4 2 8192 8192 20 8 30 reduction;

./Launcher.sh 8 16 32 256 512 20 2 30 reduction;
./Launcher.sh 8 16 32 4096 4096 20 2 30 reduction;

./Launcher.sh 32 16 32 256 512 20 8 30 reduction;
./Launcher.sh 32 16 32 4096 4096 20 8 30 reduction;

#./Launcher.sh 8 16 32 4096 4096 20 2 30 reduction 2;
#./Launcher.sh 8 16 32 4096 4096 20 2 30 reduction 4;
#./Launcher.sh 32 16 32 4096 4096 20 8 30 reduction 2;
#./Launcher.sh 32 16 32 4096 4096 20 8 30 reduction 4;