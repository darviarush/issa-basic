%{
#define YYSTYPE char*

#define _GNU_SOURCE
#include <stdio.h>

extern int yylex();
extern int yyparse();
extern FILE* yyin;

void yyerror(const char* s);

%}
%locations

%token  	A INT NUM STRING

%left '-' '+'
%left '*' '/'
%left '^'
%left U

%start start

%%

start:	lines			{ printf("%s", $1); }
;

lines:	/* пусто */		{ $$ = ""; }
		| lines line 	{ asprintf(&$$, "%s%s", $1, $2); }
;

line: 	'\n'			{ asprintf(&$$, "\n"); }
		| stmts '\n'	{ asprintf(&$$, "%s;\n", $1); }
;


stmts:	stmt ':' stmts		{ asprintf(&$$, "%s; %s", $1, $3); }
		| stmt 				{ $$ = $1; }
;

stmt:	A '=' exp			{ asprintf(&$$, "%s = %s", $1, $3); }
;

exp:	exp '+' exp			{ asprintf(&$$, "%s.$add(%s)", $1, $3); }
		| exp '-' exp		{ asprintf(&$$, "%s.$sub(%s)", $1, $3); }
		| exp '*' exp		{ asprintf(&$$, "%s.$mul(%s)", $1, $3); }
		| exp '/' exp		{ asprintf(&$$, "%s.$div(%s)", $1, $3); }
		| exp '^' exp		{ asprintf(&$$, "%s.$pow(%s)", $1, $3); }
		| '-' exp %prec U 	{ asprintf(&$$, "%s.$neg()", $2); }
		| '(' exp ')'		{ $$ = $2; }
		| A 				{ $$ = $1; }
		| INT 				{ $$ = $1; }
		| NUM 				{ $$ = $1; }
		| STRING 			{ $$ = $1; }
;
%%
