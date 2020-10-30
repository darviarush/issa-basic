%{

#include <stdio.h>
#include <stdlib.h>

extern int yylex();
extern int yyparse();
extern FILE* yyin;

void yyerror(const char* s);

%}

%union {
    int ival;
    double fval;
    char* sval;
}

//%token<ival> T_INT
//%token<fval> T_FLOAT
%token T_NEWLIN T_QUIT
%left "+" "-"
%left "*" "/"

%type<sval> mixed_expression

%start calculation

%%

calculation:
       | calculation line
;

line: "\n"
    | mixed_expression "\n" { printf("\tResult: %f\n", $1);}
    | T_QUIT "\n" { printf("bye!\n"); exit(0); }
;

mixed_expression:
        mixed_expression "+" mixed_expression	{ $$ = $1 + $3; }
      | mixed_expression "-" mixed_expression	{ $$ = $1 - $3; }
      | mixed_expression "*" mixed_expression	{ $$ = $1 * $3; }
      | mixed_expression "/" mixed_expression	{ $$ = $1 / $3; }
      | "(" mixed_expression ")"		{ $$ = $2; }
      | T_VAR { $$ = {type: , s: $1}; }
      | T_INT { $$ = $1; }
      | T_FLOAT { $$ = $1; }
;


%%

int main() {
    yyin = stdin;

    do {
	yyparse();
    } while(!feof(yyin));

    return 0;
}

void yyerror(const char* s) {
    fprintf(stderr, "Parse error: %s\n", s);
    exit(1);
}
