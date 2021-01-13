#include <string.h>
#include <malloc.h>

#include "node.h"


node* new_node(node* from) {
	node* n = (node*) malloc(sizeof(node));
	memcpy(n, from, sizeof(node));
	return n;
}

node* op_node(int op, node* op1, char* text, node* op2) {
	node n = {
		first_line   : op1->first_line,
		first_column : op1->first_column,
		last_line 	 : op2->last_line,
		last_column  : op2->last_column,
		text 		 : text,
		op 			 : op,
		left		 : op1,
		right		 : op2,
	};

	return new_node(&n);
}

node* u_node(int op, node* op1, char* text) {
	char* s = NULL;

	node n = {
		first_line   : op1->first_line,
		first_column : op1->first_column,
		last_line 	 : op1->last_line,
		last_column  : op1->last_column,
		text 		 : text,
		op 			 : op,
		left		 : op1,
		right		 : NULL,
	};

	return new_node(&n);
}
