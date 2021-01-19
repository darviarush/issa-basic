#define _GNU_SOURCE

#include <errno.h>
#include <libgen.h>
#include <search.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>

#include "gen_code_c.h"
#include "node.h"
#include "../o/is.tab.h"


/*** Возвращаемое функцией генерации значение ***/

struct RETURN_CONTEXT {
	char* class;
	char* text;
};


/*** Контекст метода ***/

struct METHOD_CONTEXT {
	char* class;			// String
	char* method;			// word, word$type, word$type$word$type
	int calls;				// битовое множество: какой из параметров является вызовом &
	char* return_class;		// Int
};


/*** Ассоциативный массив методов ***/

static int cmp_methods(const void* a, const void* b) {
	int x = strcmp(((struct METHOD_CONTEXT*) a)->class, ((struct METHOD_CONTEXT*) b)->class);
	if(x!=0) return x;
	return strcmp(((struct METHOD_CONTEXT*) a)->method, ((struct METHOD_CONTEXT*) b)->method);
}

static void* root_methods = NULL;
static struct METHOD_CONTEXT* get_method(char* class, char* method) {
	struct METHOD_CONTEXT* x = malloc(sizeof(struct METHOD_CONTEXT));
	x->class = class;
	x->method = method;
	x->return_class = NULL;
	x->output = NULL;
	struct METHOD_CONTEXT* y = tsearch((void *) x, &root_methods, cmp_methods);
	if(y != x) free(x);
	return y;
}


/*** Декларации ***/

extern FILE* yyin;
extern int yystartrule;
extern node* yyres;

static char* bin;

char* gen_code_c(node* n, struct METHOD_CONTEXT* ctx);

/*** Функции ***/

FILE* fileopen(char* path, char* mode) {
	FILE* f = fopen(path, mode);
	if(!f) {
		fprintf(stderr, "fopen(%s, %s): %s\n", path, mode, strerror(errno));
		exit(errno);
	}
	return f;
}

void md(char* dir) {
	int res = mkdir(dir, 0700);
	if(res != 0 && errno != EEXIST) mse("mkdir(%s): %s", dir, strerror(errno));
}


char* compile_method(char* class, char* method) {

	struct METHOD_CONTEXT* ret = get_method(class, method);
	if(ret->return_class != NULL)
		return ret->return_class;

	char* infile = asp("barsum/%s/%s.is", class, method);
	yyin = fileopen(infile, "r");
	yystartrule = METHOD;
	yyparse();

	char* class_dir = asp(".issa/%s/%s", bin, class);
	md(class_dir);
	free(class_dir);
	char* outfile = asp(".issa/%s/%s/%s.c", bin, class, method);	

	char* text = gen_code_c(yyres, ret);

	FILE* f = fileopen(outfile, "w");
	fprintf(f, "%s", text);
	fclose(f);

	free(outfile);
	free(infile);
}

char* gen_code_c(node* n, struct METHOD_CONTEXT* ctx) {

	FILE* output = ctx->output;

	switch(n->op) {

		case '\f':

			FILE* r;
			char* return_class = ctx->class;
			char* buf;
			size_t size;

			if(n->right->op == '\r') {
				FILE* f = ctx->output;
				ctx->output = open_memstream(&buf, &size);
				return_class = gen_code_c(n->right, ctx);
				fclose(ctx->output);
				ctx->output = f;
			}

			if(n->left->op == WORD) {
				fprintf(output, "%1$s$ %1$s$%2$s() {\n", class, method);
			}
			else {
				gen_code_c(n->left, ctx);
			}
			
			
			fprintf(output, "%s}\n", buf);
			free(buf);
			break;
		case '\r':
			gen_code_c(n->left, ctx);
			fprintf(output, "return ");
			return gen_code_c(n->right, ctx);
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
				fprintf(stderr, "op = `%c`? Not exists!\n", n->op);
			else 
				fprintf(stderr, "op = #%i? Not exists!\n", n->op);
			exit(2);
	}

	return NULL;
}

/* 
	генерирует код для программы
 	создаётся такая структура файлов:
 		.issa/
			outfile/
				class/
					method.c
					method.o
					...
				...
				Makefile
				signatures.txt
*/
void gen_code_c_prog(char* binfile, char* class) {
	
	bin = basename(binfile);

	md(".issa");

	char* outdir = asp(".issa/%s");
	md(outdir);
	free(outdir);

	msg("bin=%s class=%s", bin, class);

	compile_method(class, "run");

	char* outfile;
	asprintf(&outfile, ".issa/%s/main.c", bin);
	FILE* o = fileopen(outfile, "w");

	fprintf(o,
		"include \"%1s/_class.h\"\n"
		"\n"
		"int main(int ac, char** av, char** ep) {\n"
		"	\n"
		"	%1$s$ a = %1$s$alloc();\n"
		"	a->ac = ac;\n"
		"	a->av = av;\n"
		"	a->ep = ep;\n"
		"	%1$s$run(a);\n"
		"	%1$s$free(a);\n"
		"	\n"
		"	return 0;\n"
		"}\n",
		class);

	fclose(o);
	free(outfile);
}
