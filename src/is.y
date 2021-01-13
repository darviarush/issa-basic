%{

#define _GNU_SOURCE
#include <stdio.h>

#include "../src/node.h"

extern int yylex();
extern int yyparse();
extern FILE* yyin;

void yyerror(const char* s);

node* yyres = NULL;

%}

%define parse.trace
%define parse.error verbose


%token  	A INT NUM STRING

%left '\n'
%left ':'
%left METHOD
%left '-' '+'
%left '*' '/'
%left '^'
%left U

%start start

%%

start:	stmt				{ yyres = $1; }
;


stmt:	stmt '\n' stmt		{ $$ = $1 && $3? op_node('\n', $1, NULL, $3):
								$1? u_node('\n', $1, NULL):
								$3? u_node('\n', $3, NULL):
								$2;	}
		| stmt ':' stmt		{ $$ = op_node(':', $1, NULL, $3); }
		| A '=' exp			{ $$ = op_node('=', $1, NULL, $3); }
		| /* empty */		{ $$ = NULL; }
;

exp:	exp METHOD exp		{ $$ = op_node(METHOD, $1, $2->text, $3); }
		| exp '+' exp		{ $$ = op_node(METHOD, $1, "add", $3); }
		| exp '-' exp		{ $$ = op_node(METHOD, $1, "sub", $3); }
		| exp '*' exp		{ $$ = op_node(METHOD, $1, "mul", $3); }
		| exp '/' exp		{ $$ = op_node(METHOD, $1, "div", $3); }
		| exp '^' exp		{ $$ = op_node(METHOD, $1, "pow", $3); }
		| '-' exp %prec U	{ $$ = u_node(U, $2, "neg"); }
		| '(' exp ')'		{ $$ = $2; }
		| A 				{ $$ = $1; }
		| INT 				{ $$ = $1; }
		| NUM 				{ $$ = $1; }
		| STRING 			{ $$ = $1; }
;
%%
