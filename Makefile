.PHONY: all


all: is
	./is < one-page-example.is

o/is.tab.c o/is.tab.h: src/is.y
	bison src/is.y -o o/is.tab.c --defines=o/is.tab.h

o/is.y.o: o/is.tab.c
	gcc -o o/is.y.o -c o/is.tab.c

o/main.o: src/main.c o/is.tab.h
	gcc -o o/main.o -c src/main.c

o/lex.yy.c: src/is.l o/is.tab.h
	flex -o o/lex.yy.c src/is.l

o/is.l.o: o/lex.yy.c
	gcc -c o/lex.yy.c -o o/is.l.o

is: o/is.l.o o/is.y.o o/main.o
	gcc -o is o/is.l.o o/is.y.o o/main.o

re: clean all

clean:
	rm -f o/* is

