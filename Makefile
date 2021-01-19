.PHONY: all

BFLAGS = -Wcounterexamples -Wdangling-alias -r all 

objects := $(patsubst src/%.c,o/%.o,$(wildcard src/*.c))


all: is
	#./is < one-page-example.is
	#strace ./is bin/test-issa TestIssa
	./is bin/test-issa TestIssa

is: o/is.l.o o/is.y.o $(objects)
	gcc -o $@ $^

o/is.tab.c o/is.tab.h: src/is.y src/node.h
	bison $(BFLAGS) src/is.y -o o/is.tab.c --defines=o/is.tab.h

o/is.y.o: o/is.tab.c
	gcc -o o/is.y.o -c o/is.tab.c

o/lex.yy.c: src/is.l o/is.tab.h src/node.h
	flex -o o/lex.yy.c src/is.l

o/is.l.o: o/lex.yy.c
	gcc -c o/lex.yy.c -o o/is.l.o

o/%.o: src/%.c src/%.h
	gcc -o $@ -c $<

o/%.o: src/%.c
	gcc -o $@ -c $<

re: clean all

clean:
	rm -f o/* is

