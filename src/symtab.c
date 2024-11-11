/******************************************************************************/
/* cc442: A Sweet C-Like Compiler for CS 442                                  */
/*                                                                            */
/* University of Wisconsin-La Crosse                                          */
/* Department of Computer Science & Computer Engineering                      */
/* (c) 2023  Elliott Forbes (eforbes@uwlax.edu)                               */
/*                                                                            */
/* DO NOT DISTRIBUTE                                                          */
/*                                                                            */
/******************************************************************************/
/* symtab.c                                                                   */
/* Functions to implement the symbol table.                                   */
/******************************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "symtab.h"
#include "pdefs.h"

// The head of the linked-list of symbol table 
// entries. Marked static so that the symtab_head 
// cannot be accessed outside of this file.
static symtab_entry_t * symtab_head = NULL;

// Insert a new symbol table entry with given name and type. 
// This should first check to make sure the name doesn't 
// already exist at the scope determined by entry_type (it's 
// ok to have the same name at different scope once scoping is 
// implemented). Once you're sure the name doesn't already 
// exist, then allocate a new symtab_entry_t, a node in a 
// singly-linked list, and link it into the list. If the 
// name already exists, then yyerror out.


//test1.c NOW WORKS
//test2.c DOES NOT, WHICH IS WHAT IS SUPPOSED TO HAPPEN SO WE'RE GOOD!


void symtab_new(char* name, symtab_type_t entry_type){
    if (symtab_head == NULL) {
        symtab_entry_t * newHeadEntry = malloc(sizeof(symtab_entry_t));
        symtab_head = newHeadEntry;
        //R: do we also need to allocate memory for name with newHeadEntry->name = strdup(name); instead maybe?
            // T: I believe so!
        newHeadEntry->name = strdup(name);
        newHeadEntry->type = entry_type;
    } else {
        symtab_entry_t * curr = symtab_head;
        while (curr != NULL) {
            //Changed to strcomp instead of ==
            if (strcmp(curr->name, name) == 0) {
                yyerror("Name already exists in symbol table");
            }
            if(curr->next == NULL)
                break;
            curr = curr->next;
        }
        // Tarren: if we've gotten to this point and haven't yyerrored,
        // we can be sure that the name doesn't already exist & can safely
        // allocate & add a new symtab_entry_t. (and we can also be sure that
        // we're at the end of the linked list)
        symtab_entry_t * newEntry =  malloc(sizeof(symtab_entry_t));
        newEntry->name = strdup(name);
        newEntry->type = entry_type;
        curr->next = newEntry;
    }
}

// Update the "payload" associated with a name. The 
// payload is an offset (an int value) for a local 
// variable or a function_t instance if the name is 
// related to a function definition. 
//
// This function should check that the name exists 
// first, and gives a yyerror if the name isn't defined. 
void symtab_update(char* name, void *payload){
    symtab_entry_t * curr = symtab_head;
    int foundName = 0;
    while (curr) {
        //R: curr->name == name compares pointers to the same memory location, we want to compare strings so need to use strcmp
        if (strcmp(curr->name, name) == 0) {
            curr->payload = payload;
            foundName = 1;
            break;
        }
        curr = curr->next;
    }
    // Tarren: if we didn't find it yet, then it doesn't exist B)
    if (foundName == 0)
        (yyerror("Update unsuccessful; name not found"));
}

// Return the "payload" associated with a name. If 
// the name doesn't exist, then yyerror out.
void *symtab_lookup(char* name){
    symtab_entry_t * curr = symtab_head;
    while (curr) {
        //R: Same here need to strcmp
        //R:Is the second part of this or statement needed?
            // T: I don't think so, and I'm not super sure what I was doing here lol
        if (strcmp(curr->name, name) == 0) {
            return curr->payload;
        }
        curr = curr->next;
    }
    yyerror("Lookup(payload) unsuccessful; name not found");
    return NULL; 
}

// Return the type (local int variable, vs global int variable, 
// etc) for  a given name. Call yyerror if the name 
// isn't found
symtab_type_t symtab_type(char* name){
    symtab_entry_t * curr = symtab_head;
    while (curr) {
        //R: same thing compare strings instead of memeory addr
        if (strcmp(curr->name, name) == 0) {
            return curr->type;
        }
        curr = curr->next;
    }
    yyerror("lookup(type) unsuccessful; name not found");
    return -1;
}

// This is just a debugging helper function to just 
// dump the contents of the symbol table to stdout. 
// the main function in the parser has a call to this 
// function, commented out. Uncomment to dump the symbol 
// table after your compiler parses the entire input program.
void dump_symtab(){
    // Tarren: Improved the look of the output
    int i = 0;
    symtab_entry_t *working = symtab_head;
    i = 0;
    printf("\nSymbol table entries: \n");
    while (working){
        printf("entry[%d]: \n", i);
        printf("* \t name: %s\n", working->name);
        switch(working->type) {
            case SYMTAB_INTGLOBAL:
                printf("* \t type: int\n");
                printf("* \t scope: global\n");
                break;
            
            case SYMTAB_INTLOCAL:
                printf("* \t type: int\n");
                printf("* \t scope: local\n");
                break;

            case SYMTAB_ARRAYGLOBAL:
                printf("* \t type: array\n");
                printf("* \t scope: global\n");
                break;
            
            case SYMTAB_ARRAYLOCAL:
                printf("* \t type: array\n");
                printf("* \t scope: local\n");
                break;

            case SYMTAB_STRGLOBAL:
                printf("* \t type: string\n");
                printf("* \t scope: global\n");
                break;

            case SYMTAB_STRLOCAL:
                printf("* \t type: string\n");
                printf("* \t scope: local\n");
                break;

            case SYMTAB_FUNC:
                printf("* \t type: function\n");
                printf("* \t scope: \n"); // Tarren: IDK what to put here lol
                break;
        }
        if (working->payload) {
            printf("* \t payload: %d\n", *((int*) working->payload));
        } else {
            printf("* \t payload: NULL\n");
        }   
        // TODO: need to add more print statements for the 
        // other symbol table types and scope, once implemnted
        i++;
        working = working->next;
    }
}

