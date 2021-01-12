#include <stdio.h>
#include <stdlib.h>

#include "../o/is.tab.h"

extern char* yytext;
extern int yylineno;

int yywrap() {
	return 1;
}

void yyerror(const char* s) {
	fprintf(stderr, "%i:%i %s on `%s`\n", 
		yylloc.first_line,
		yylloc.first_column,	// last_line last_column
		s, 
		yytext);
	exit(1);
}


int main() {

	return yyparse();
}
