.SILENT:

default:
	nasm -f macho source.asm -g
	ld -o game -e mystart source.o

run: default
	./game