ASM = nasm
ASM_OPTIONS = -f elf64

GXX = g++

all: shader
	
main.o:
	$(GXX) -c main.cpp -o main.o

x86_function.o:
	$(ASM) $(ASM_OPTIONS) x86_function.asm

shader: x86_function.o main.o
	$(GXX) main.o x86_function.o -o shader

clean:
	rm *.o
	rm shader
