%option noyywrap

%{
#include <stdio.h>

#define YY_DECL int yylex()

#include "issa.tab.h"

%}

op		[-*+/\n()]

string		"([^\"]|\\\")*"

word		[a-zA-Z_][a-zA-Z_0-9]+
var		[a-z]
register	[A-Z]

%%

[ \t]+				; // ignore all whitespace
[0-9]+\.[0-9]+			yylval.fval = atold(yytext);  return T_FLOAT;
[0-9]+				yylval.ival = atoi(yytext);   return T_INT;
{string}			yylval.sval = strdup(yytext); return T_STRING;

{word}				yylval.sval = strdup(yytext); return T_WORD;
{var}				yylval.sval = strdup(yytext); return T_VAR;
{register}			yylval.sval = strdup(yytext); return T_REGISTER;
{op}				return *yytext;


%%
