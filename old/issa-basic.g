# §§ язык программирования Issa-Basic

# §1. Правила лексического анализа

# Пропускаем пробелы
~pass	= [ \t]+

# Операторы объявляем токенами
~op		= "<>"|"<="|"=>"|"|"|"+"|"-"|"*"|"/"|"^"|"="|":"|"("|")"|"<"|">"|"&"|"$"|"%"|"!"|"#"|","|";"|"\n"

# Остальные токены
NUM		= [0-9]+\.[0-9]+
INT 	= [0-9]+
STRING  = "([^"]|\\\")*"\""

RETURN  = ^return\b


# §2. Таблица операторов

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

# Неявные токены
%token		METHOD LINES EXP

# §3. Грамматика


start: METHOD method
		| LINES lines
		| EXP exp


method:	signature '\n' lines ret

ret:	RETURN exp
		| %empty

signature: WORD
		| arguments

arguments: argument arguments
		| argument

argument: WORD A
		| WORD '&' A

lines:	lines '\n' lines
		| IF exp THEN stmt
		| FOR A '=' exp
		| NEXT next
		| stmt
		| %empty

next:	next ',' next
		| A

stmt:	stmt '|' stmt
		| stmt ':' stmt
		| A '=' exp
		| WORD exp

exp:	exp OR exp
		| exp AND exp
		| NOT exp

		| exp '<' exp
		| exp '>' exp
		| exp '=' exp
		| exp AT_MOST exp
		| exp AT_LEAST exp
		| exp NE exp


		| exp WORD exp
		| exp ',' exp
		| exp ';' exp

		| exp '+' exp
		| exp '-' exp
		| exp '*' exp
		| exp '/' exp
		| exp '^' exp
		| '-' exp %prec U
		| exp '$'
		| exp '%'
		| exp '!'
		| exp '#'
		| exp WORD %prec UMETHOD
		| '(' exp ')'
		| A
		| INT
		| NUM
		| STRING

