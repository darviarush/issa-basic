all: issa

o/issa.tab.c o/issa.tab.h: src/issa.y
	bison -t -v -d src/issa.y
	mv issa.tab.c issa.tab.h issa.output o/

o/lex.yy.c: src/issa.l o/issa.tab.h
	flex src/issa.l
	mv lex.yy.c o/

issa: o/lex.yy.c o/issa.tab.c o/issa.tab.h
	gcc -o issa o/issa.tab.c o/lex.yy.c

clean:
	rm issa o/* issa.output
