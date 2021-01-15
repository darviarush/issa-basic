#include <stdio.h>
#include <stdlib.h>

#include "gen_code_c.h"



int main(int ac, char** av) {

	gen_code_c_prog(av[0], av[1]);

	return 0;
}
