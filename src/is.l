%{
#define YY_DECL int yylex()

#include <string.h>

#include "../src/node.h"
#include "is.tab.h"


int yystartrule;
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

#define RET(A, B)	if(strcmp(yytext, A) == 0) return B

%}
%option yylineno

op		"|"|"+"|"-"|"*"|"/"|"^"|"="|":"|"("|")"|"<"|">"|"&"|"$"|"%"|"!"|"#"|","|";"

num		[0-9]+\.[0-9]+
int 	[0-9]+
string  \"([^\"]|\\\")*"\""

%%

							if(yystartrule) {
								int yystartrule_prev = yystartrule;
								yystartrule = 0;
								return yystartrule_prev;
							}

[a-zA-Z][a-zA-Z_0-9]*		{
								if(yyleng == 1) return new_yylval(A);

								yycolumn += yyleng;

								if(yycolumn - yyleng == 1) {
									RET("return", RETURN);
									RET("if", IF);
									RET("for", FOR);
									RET("next", NEXT);
								}
								RET("and", AND);
								RET("or", OR);
								RET("not", NOT);
								RET("then", THEN);

								yycolumn -= yyleng;
								return new_yylval(WORD);
							}
{string}		return new_yylval(STRING);
{num}			return new_yylval(NUM);
{int}			return new_yylval(INT);

"<="			yycolumn += yyleng; return AT_MOST;
"=>"			yycolumn += yyleng; return AT_LEAST;
"<>"			yycolumn += yyleng; return NE;
{op}			yycolumn += yyleng; return *yytext;

[ \t]+			yycolumn += yyleng;
\n				{ new_yylval('\n'); yycolumn = 1; return '\n'; }
.				fprintf(stderr, "%i:%i Undefined simbol `%s`\n", yylineno, yycolumn, yytext); exit(10);
<<EOF>>			return 0;
%%
