.PHONY: all


all: is


is: lex.o
	gcc -o is is.c

