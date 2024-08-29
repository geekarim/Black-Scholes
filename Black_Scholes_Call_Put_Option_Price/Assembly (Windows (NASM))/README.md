# Instruction
Move black_scholes.asm to the folder where the nasm.exe is located

Using the cmd, navigate to the folder where the nasm.exe is located
cd ~/nasm

Run the following command:
nasm -f win32 black_scholes.asm -o black_scholes.obj && gcc black_scholes.obj -o black_scholes.exe -m32 -lmsvcrt && black_scholes.exe