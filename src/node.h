#ifndef __NODE__H__
#define __NODE__H__

typedef struct NODE {
	int first_line;
	int first_column;
	int last_line;
	int last_column;

	char* text;
	int op;

	struct NODE* left;
	struct NODE* right;

} node;

#define YYSTYPE node*


node* new_node(node* from);
node* op_node(int op, node* op1, char* text, node* op2);
node* u_node(int op, node* op1, char* text);

// ----
#define msg(FMT, ARGS...)		fprintf(stderr, FMT "\n", ##ARGS)
#define mse(FMT, ARGS...)		fprintf(stderr, FMT "\n", ##ARGS), exit(1)

#define asp(FMT, ARGS...)		({char* s; asprintf(&s, FMT, ##ARGS); s; })

#endif
