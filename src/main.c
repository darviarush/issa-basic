#include <stdio.h>
#include <stdlib.h>

#include "gen_code_c.h"
#include "../o/is.tab.h"

extern char* yytext;
extern int yylineno;
extern int yycolumn;
extern node* yyres;

int yywrap() {
	return 1;
}

void yyerror(char const *s) {
	fprintf(stderr, "%i:%i %s on `%s`\n", 
		yylineno,
		yycolumn,	// last_line last_column
		s,
		yytext);
	exit(1);
}


int main() {
	int status = yyparse();
	if(status) return status;

	gen_code_c(yyres);

	return 0;
}
