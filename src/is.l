%{
#define YY_DECL int yylex()

#include <string.h>

#include "../src/node.h"
#include "is.tab.h"


int yycolumn = 1;

static int new_yylval(int op) {

	//fprintf(stderr, "%i:%i `%s`\n", yylineno, yycolumn, yytext);

	node n = {
		first_line   : yylineno,
		first_column : yycolumn,
		last_line 	 : yylineno,
		last_column  : yycolumn + yyleng - 1,
		text 		 : strdup(yytext),
		op 			 : op,
		left		 : NULL,
		right		 : NULL,
	};
	yylval = new_node(&n);
	yycolumn += yyleng;

	return op;
}

%}
%option yylineno

op		"|"|"+"|"-"|"*"|"/"|"^"|"="|":"|"("|")"

num		[0-9]+\.[0-9]+
int 	[0-9]+
string  \"([^\"]|\\\")*"\""

%%

[a-zA-Z][a-zA-Z_0-9]+		return new_yylval(METHOD);
[a-zA-Z]		return new_yylval(A);
{string}		return new_yylval(STRING);
{num}			return new_yylval(NUM);
{int}			return new_yylval(INT);
{op}			yycolumn += yyleng; return *yytext;
[ \t]+			yycolumn += yyleng;
\n				{ new_yylval('\n'); yycolumn = 1; return '\n'; }
.				fprintf(stderr, "%i:%i Undefined simbol `%s`\n", yylineno, yycolumn, yytext); exit(10);
<<EOF>>			return 0;
%%
