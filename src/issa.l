%option noyywrap

%{
#include <stdio.h>

#define YY_DECL int yylex()

#include "issa.tab.h"

%}

op		[-*+/\n()]

string		"([^\"]|\\\")*"

%%

[ \t]+		; // ignore all whitespace
[0-9]+\.[0-9]+ 	yylval.fval = atod(yytext); return T_FLOAT;
[0-9]+		yylval.ival = atoi(yytext); return T_INT;
{string}	yylval.sval = strdup(yytext); return T_STRING;
{op}		return *yytext;
"exit"|"quit"	return T_QUIT;

%%
