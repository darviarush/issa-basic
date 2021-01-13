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
%token		IF THEN
%token 		AT_MOST AT_LEAST NE

%left '\n'
%left ':'
%left AND
%left OR
%left NOT
%left METHOD
%left '-' '+'
%left '*' '/'
%left '^'
%left U

%start start

%%

start:	lines				{ yyres = $1; }
;


lines:	lines '\n' lines	{ $$ = $1 && $3? op_node('\n', $1, NULL, $3):
								$1? u_node('\n', $1, NULL):
								$3? u_node('\n', $3, NULL):
								$2;	}
		| IF lg THEN stmt	{ $$ = op_node(IF, $2, NULL, $4); }
		| stmt				{ $$ = $1; }
		| /* empty */		{ $$ = NULL; }
;

stmt:	stmt ':' stmt		{ $$ = op_node(':', $1, NULL, $3); }
		| A '=' exp			{ $$ = op_node('=', $1, NULL, $3); }
		| exp				{ $$ = $1; }
;

lg:		lg OR lg			{ $$ = op_node(METHOD, $1, "or", $3); }
		| lg AND lg			{ $$ = op_node(METHOD, $1, "and", $3); }
		| NOT lg			{ $$ = u_node(U, $2, "not"); }
		| '(' lg ')'		{ $$ = $2; }
		| cmp				{ $$ = $1; }
;

cmp:	exp '<' exp			{ $$ = op_node(METHOD, $1, "less", $3); }
		| exp '>' exp		{ $$ = op_node(METHOD, $1, "great", $3); }
		| exp '=' exp		{ $$ = op_node(METHOD, $1, "equal", $3); }
		| exp AT_MOST exp	{ $$ = op_node(METHOD, $1, "at_most", $3); }
		| exp AT_LEAST exp	{ $$ = op_node(METHOD, $1, "at_least", $3); }
		| exp NE exp		{ $$ = op_node(METHOD, $1, "not_equal", $3); }
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
