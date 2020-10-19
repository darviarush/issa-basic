#include <stdio.h>
#include <stdlib.h>

// 

// class/x.bas -> src/class/x.[hc]
 compile_method(char* class, char* method) {
    
}


int main(int ac, char** av) {

    if(ac != 1) fprintf(stderr, "use: issa-basic <файл>\n"), exit(1);

    const char* s = av[0];

    FILE* f = fopen(s, "rb");
    if(!f) perror(s);

    char buf[1024*1024];

    while(fgets(f, buf, sizeof buf)) {
        
    }


    fclose(f);

    return 0;
}
