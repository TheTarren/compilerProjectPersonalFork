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
/* symtab.h                                                                   */
/* Functions to implement the symbol table.                                   */
/******************************************************************************/

#ifndef _SYMTAB_H_
#define _SYMTAB_H_


typedef enum {
    SYMTAB_INTLOCAL,
    SYMTAB_INTGLOBAL,
    SYMTAB_STRLOCAL,
    SYMTAB_STRGLOBAL,
    SYMTAB_ARRAYLOCAL,
    SYMTAB_ARRAYGLOBAL,
    SYMTAB_FUNC
} symtab_type_t;

// data type for one symbol table entry, which 
// will be a node in a singly-linked list
typedef struct symtab_entry_type {
    char * name;
    symtab_type_t type;
    void *payload; 
    struct symtab_entry_type * next;
} symtab_entry_t;

// data type that will eventually be used to 
// hold meta-data related to functions
typedef struct function_type {
    int numargs; // the number of args of a function
    symtab_type_t argtypes[]; // an array of data types, one for each argument
} function_t;

// prototypes for handling the symbol table, the 
// descriptions of the functions appear in symtab.c
void symtab_new(char*, symtab_type_t);
void symtab_update(char*, void*);
void *symtab_lookup(char*);
symtab_type_t symtab_type(char*);
void dump_symtab();


#endif
