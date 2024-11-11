// This is another actual C program that you 
// can use to get you started on testing your 
// implementation of the symbol table functions, 
// without relying on the full cc442 compiler.
// This is not an exhaustive test, you should 
// add more tests to ensure your symbol table 
// functions correctly.
//
// to compile: gcc -I../src/ ./symtab_driver.c ../src/symtab.c -o symtab_test
// then run with: ./symtab_test
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symtab.h"

int yyerror(const char *);

int main() {
    int offset = -8;
    int offset2 = -16;
    int *payload;
    char *name1 = strdup("variable1");
    char *name2 = strdup("variable2");

    symtab_new(name1, SYMTAB_INTGLOBAL);
    symtab_new(name2, SYMTAB_INTGLOBAL);
    
    // should see both variable1 and variable2 printed
    dump_symtab();
    

    symtab_update(name1, &offset);
    symtab_update(name2, &offset2);

    
    payload = (int*) symtab_lookup(name1);
    if ((*payload) == -8) printf("pass!\n");
    else                  printf("fail\n");
    payload = (int*) symtab_lookup(name2);
    if ((*payload) == -16) printf("pass!\n");
    else                  printf("fail\n");
    dump_symtab();

    // Tarren: some tests for symtab_type()
    int entryType1 = symtab_type(name1);
    int entryType2 = symtab_type(name2);

    printf("entry 1's type (from symtab_type()): %d\n", entryType1);
    printf("entry 2's type (from symtab_type()): %d\n", entryType2);
    
    // the following should error
    symtab_new(name2, SYMTAB_INTGLOBAL);

    return 0;
    
}

// An implementation of yyerror, some symtab functions 
// will call yyerror, and the implementation is in the 
// cc442 parser (which we don't want with this stand-
// alone symtab test). Notice this implementation won't 
// bomb this driver program out.
int yyerror(const char *s){
    fprintf(stderr,"YYERROR: %s\n",s);
    return -1;
}
