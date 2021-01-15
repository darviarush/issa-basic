%{

#define _GNU_SOURCE
#include <stdio.h>

#include "../src/node.h"

extern int yylex();
extern FILE* yyin;

void yyerror(const char* s);

node* yyres = NULL;

%}

%define parse.trace
%define parse.error verbose


%token		METHOD LINES EXP
%token  	A INT NUM STRING
%token		IF THEN
%token		RETURN
%token		FOR NEXT

%left '\n'
%left '|'
%left ':'
%left WORD
%left OR
%left AND
%left NOT
%left '<' '>' '=' AT_MOST AT_LEAST NE
%left ';'
%left ','
%left '-' '+'
%left '*' '/'
%left '^'
%left U
%left UMETHOD
%left '$' '%' '#' '!'

%start start

%%

start: METHOD method 		{ yyres = $2; }
		| LINES lines 		{ yyres = $2; }
		| EXP exp 			{ yyres = $2; }
;


method:	signature '\n' lines ret { 
	if(!$4) $$ = op_node('\f', $1, NULL, $3); }
;

ret:	RETURN exp			{ $$ = u_node(RETURN, $2, NULL); }
		| /* empty */		{ $$ = NULL; }
;

signature: WORD				{ $$ = $1; }
		| arguments 		{ $$ = $1; }
;

arguments: argument arguments	{ $$ = op_node(',', $1, NULL, $2); }
		| argument 				{ $$ = $1; }
;

argument: WORD A 			{ $$ = op_node('\a', $1, NULL, $2); }
		| WORD '&' A		{ $$ = op_node('\b', $1, NULL, $3); }
;

lines:	lines '\n' lines	{ $$ = $1 && $3? op_node('\n', $1, NULL, $3):
								$1? u_node('\n', $1, NULL):
								$3? u_node('\n', $3, NULL):
								$2;	}
		| IF exp THEN stmt	{ $$ = op_node(IF, $2, NULL, $4); }
		| FOR A '=' exp		{ $$ = op_node(FOR, $2, NULL, $4); }
		| NEXT next 		{ $$ = u_node(NEXT, $2, NULL); }
		| stmt				{ $$ = $1; }
		| /* empty */		{ $$ = NULL; }
;

next:	next ',' next 		{ $$ = op_node(',', $1, NULL, $3); }
		| A 				{ $$ = $1; }
;

stmt:	
		stmt '|' stmt		{ $$ = op_node(WORD, $1, "OR", $3); }
		| stmt ':' stmt		{ $$ = op_node(':', $1, NULL, $3); }
		| A '=' exp			{ $$ = op_node('=', $1, NULL, $3); }
		| WORD exp			{ $$ = op_node('=', $1, NULL, $2); }
;

exp:	exp OR exp			{ $$ = op_node(WORD, $1, "or", $3); }
		| exp AND exp		{ $$ = op_node(WORD, $1, "and", $3); }
		| NOT exp			{ $$ = u_node(U, $2, "not"); }

		| exp '<' exp		{ $$ = op_node(WORD, $1, "less", $3); }
		| exp '>' exp		{ $$ = op_node(WORD, $1, "great", $3); }
		| exp '=' exp		{ $$ = op_node(WORD, $1, "equal", $3); }
		| exp AT_MOST exp	{ $$ = op_node(WORD, $1, "at_most", $3); }
		| exp AT_LEAST exp	{ $$ = op_node(WORD, $1, "at_least", $3); }
		| exp NE exp		{ $$ = op_node(WORD, $1, "not_equal", $3); }


		| exp WORD exp		{ $$ = op_node(WORD, $1, $2->text, $3); }
		| exp ',' exp		{ $$ = op_node(',', $1, NULL, $3); }
		| exp ';' exp		{ $$ = op_node(';', $1, NULL, $3); }

		| exp '+' exp		{ $$ = op_node(WORD, $1, "add", $3); }
		| exp '-' exp		{ $$ = op_node(WORD, $1, "sub", $3); }
		| exp '*' exp		{ $$ = op_node(WORD, $1, "mul", $3); }
		| exp '/' exp		{ $$ = op_node(WORD, $1, "div", $3); }
		| exp '^' exp		{ $$ = op_node(WORD, $1, "pow", $3); }
		| '-' exp %prec U	{ $$ = u_node(U, $2, "neg"); }
		| exp '$'			{ $$ = u_node(U, $2, "asString"); }
		| exp '%'			{ $$ = u_node(U, $2, "asInteger"); }
		| exp '!'			{ $$ = u_node(U, $2, "asFloat"); }
		| exp '#'			{ $$ = u_node(U, $2, "asDouble"); }
		| exp WORD %prec UMETHOD { $$ = u_node(U, $1, $2->text); }
		| '(' exp ')'		{ $$ = $2; }
		| A 				{ $$ = $1; }
		| INT 				{ $$ = $1; }
		| NUM 				{ $$ = $1; }
		| STRING 			{ $$ = $1; }
;
%%

extern char* yytext;
extern int yylineno;
extern int yycolumn;
extern node* yyres;
extern int yystartrule;
extern FILE* yyin;

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

node* parse_method(FILE* f) {
	yystartrule = METHOD;
	yyin = f;
	yyparse();
	return yyret;
}

node* parse_lines(FILE* f) {
	yystartrule = LINES;
	yyin = f;
	yyparse();
	return yyret;
}

node* parse_ext(FILE* f) {
	yystartrule = EXT;
	yyin = f;
	yyparse();
	return yyret;
}
