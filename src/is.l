%{
#define YY_DECL int yylex()
#define YYSTYPE char*

#include <string.h>

#include "is.tab.h"


static void update_loc(){
  static int curr_line = 1;
  static int curr_col  = 1;

  yylloc.first_line   = curr_line;
  yylloc.first_column = curr_col;

  {char * s; for(s = yytext; *s != '\0'; s++){
    if(*s == '\n'){
      curr_line++;
      curr_col = 1;
    }else{
      curr_col++;
    }
  }}

  yylloc.last_line   = curr_line;
  yylloc.last_column = curr_col-1;
}

#define YY_USER_ACTION update_loc();

%}
%option yylineno

op		"|"|"+"|"-"|"*"|"/"|"^"|"\n"|"="|":"|"("|")"

num		-?\d+\.\d+
string  \"([^\"]|\\\")*"\""

%%

\b[a-zA-Z]\b	yylval = strdup(yytext); return A;
{string}		yylval = strdup(yytext); return STRING;
{num}			yylval = strdup(yytext); return NUM;
-?\d+			yylval = strdup(yytext); return INT;
{op}			return *yytext;

%%
