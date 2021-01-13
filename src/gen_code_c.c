#include <stdio.h>
#include <stdlib.h>

#include "gen_code_c.h"
#include "../o/is.tab.h"


void gen_code_c(node* n) {

	switch(n->op) {
		case '\n':
			if(n->left) gen_code_c(n->left);
			printf("\n");
			if(n->right) gen_code_c(n->right), printf(";");
			break;
		case ':':
			gen_code_c(n->left);
			printf("; ");
			gen_code_c(n->right);
			break;
		case '=':
			gen_code_c(n->left);
			printf(" = ");
			gen_code_c(n->right);
			break;
		case A:
			printf("%s", n->text);
			break;
		case INT:
			printf("%s", n->text);
			break;
		case NUM:
			printf("%s", n->text);
			break;
		case STRING:
			printf("%s", n->text);
			break;
		case U:
			printf("%s(", n->text);
			gen_code_c(n->left);
			printf(")");
			break;
		case METHOD:
			printf("%s(", n->text);
			gen_code_c(n->left);
			printf(", ");
			gen_code_c(n->right);
			printf(")");
			break;
		default:
			if(32 <= n->op && n->op < 127)
				fprintf(stderr, "op = `%c`? Not exists!\n", n->op);
			else 
				fprintf(stderr, "op = `%i`? Not exists!\n", n->op);
			exit(2);
	}
}
