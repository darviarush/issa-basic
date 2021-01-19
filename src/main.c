#include <stdio.h>
#include <stdlib.h>

#include "node.h"
#include "gen_code_c.h"



int main(int ac, char** av) {

	if(ac != 3) mse("usage: %s outfile class", av[0]);

	gen_code_c_prog(av[1], av[2]);

	return 0;
}
