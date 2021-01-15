#include <stdio.h>
#include <stdlib.h>

#include "gen_code_c.h"
#include "node.h"
#include "../o/is.tab.h"

static FILE* output;


void gen_code_c(node* n) {

	switch(n->op) {

		case '\n':
			if(n->left) gen_code_c(n->left);
			fprintf(output, "\n");
			if(n->right) gen_code_c(n->right), fprintf(output, ";");
			break;
		case ':':
			gen_code_c(n->left);
			fprintf(output, "; ");
			gen_code_c(n->right);
			break;
		case IF:
			fprintf(output, "if(");
			gen_code_c(n->left);
			fprintf(output, ") {");
			gen_code_c(n->right);
			fprintf(output, "}");
			break;
		case '=':
			gen_code_c(n->left);
			fprintf(output, " = ");
			gen_code_c(n->right);
			break;
		case A:
			fprintf(output, "%s", n->text);
			break;
		case INT:
			fprintf(output, "%s", n->text);
			break;
		case NUM:
			fprintf(output, "%s", n->text);
			break;
		case STRING:
			fprintf(output, "%s", n->text);
			break;
		case U:
			fprintf(output, "%s(", n->text);
			gen_code_c(n->left);
			fprintf(output, ")");
			break;
		case WORD:
			fprintf(output, "%s(", n->text);
			gen_code_c(n->left);
			fprintf(output, ", ");
			gen_code_c(n->right);
			fprintf(output, ")");
			break;
		default:
			if(32 <= n->op && n->op < 127)
				ffprintf(output, stderr, "op = `%c`? Not exists!\n", n->op);
			else 
				ffprintf(output, stderr, "op = #%i? Not exists!\n", n->op);
			exit(2);
	}
}


# открывает файл
FILE* openfile(char* path, char* mode) {
	FILE* f = fopen(path, mode);
	if(!f) {
		fprintf(stderr, "fopen(%s, %s): %s\n", path, mode, strerr(errno));
		exit(errno);
	}
	return f;
}

# генерирует код для программы
void gen_code_c_prog(char* outfile, char* class) {
	output = openfile(outfile, "w");	
	
}
