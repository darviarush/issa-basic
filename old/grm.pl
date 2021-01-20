mkdir "grm", 0755;


open f, "< issa-basic.g" or die $!;
open yf, "> src/issa-basic.y" or die $!;
open lf, "> src/issa-basic.l" or die $!;

while(<f>) {
	next if /^#/;
	next if /^\s*$/;

	push(@R, $_), next if /^%/;

	
}


print yf << END;

%{

#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>

#include "../src/node.h"

extern int yylex();
extern FILE* yyin;

void yyerror(const char* s);

node* yyres = NULL;

%}

%define parse.trace
%define parse.error verbose

@R

%start start

%%

END
