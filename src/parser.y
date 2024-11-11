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
    /* parser.y                                                                   */
    /* The parser rules and actions for the cc442 parser.                         */
    /*                                                                            */
    /******************************************************************************/


%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "tnmarch.h"
#include "inst.h"
#include "mem.h"
#include "output.h"
#include "symtab.h"
#include "pdefs.h"
#include "util.h"


/* set to 1 to trace the parser when you run cc442 on input program */
#define YYDEBUG 0

/* a variable you can use to access as many virtual regs as you need,
   just remember to vreg++ every time you use another one */
int vreg = 6;

/* a variable you can use to keep track of how many global
   variables there are (to give offsets from the global pointer */
int nglobals = 0;
/* and the locals too */
int nlocals = 0;
%}

// the union of possible yylval types and parser types
%union {
    char *string;
    int ivalue;
    struct instruction_type *instr;
    struct expr_result_type *exres;
}


/* T: NOTE: Will need to yeet the following code into the NT w/ bitwise NOT ++x, * (ptr),
    etc. as logical & bitwise NOT have the same precedence as each other together in a big
    group much higher in the OOP (for no discernable reason):

    | LOGICNOT expr{ //need to return 1 if expr == 0, and 0 if expr != 0
        instruction_t * inst = new_instruction(NULL, SEQI_OPCODE, vreg++, $2->reg, 0, NULL);
        $$ = new_expr_result(inst->rdest, inst, EXPR_INT);
    }

*/


// scanner tokens (terminals)
%token IFKEY ELSEKEY WHILEKEY
%token SEMI

%token INTKEY STRKEY
%token EXIT PUTINT PUTS GETINT GETS MALLOC

%token PLUS MINUS MULTIPLY DIVIDE
%token AND OR NOT XOR
%token LSHIFT RSHIFT
%token LT GT LTE GTE EQ NEQ
%token ASSIGN

%token LOGICNOT LOGICAND LOGICOR

%token <string> IDENT
%token <ivalue> INTLIT
%token <string> STRINGLIT

%token LBRACKET RBRACKET
%token LBRACE RBRACE
%token LPAREN RPAREN
%token COLON COMMA

%token UNKNOWN

// parser non-terminals
%type <exres> factor term expr
//R: added the line under this comment
%type <exres> logicand bitor bitxo bitand lequal compare
%type <exres> shift nott plusminus
%type <instr> statement sequence
%type dec declarations
%type prog 

%%

// top-level of a cc442 program:
prog: declarations sequence {
        // generate the exit system call and add to
        // tail of list of instructions
        instruction_t *syscode = new_instruction(NULL, LI_OPCODE, vreg++, 0, 0, SYSCALL_EXIT, NULL);
        instruction_t *arg = new_instruction(NULL, SW_OPCODE, 0, syscode->rdest, REG_SP, 0, NULL);
        instruction_t *sysc = new_instruction(NULL, SYSCALL_OPCODE, 0, 0, 0, 0, NULL);
        instruction_t *combined;
        combined = append_inst(syscode, arg);
        combined = append_inst(combined, sysc);
        combined = append_inst($2, combined);

        // assign to head of instruction list
        inst_list = combined;
    }
    | sequence declarations {
        // generate the exit system call and add to
        // tail of list of instructions
        instruction_t *syscode = new_instruction(NULL, LI_OPCODE, vreg++, 0, 0, SYSCALL_EXIT, NULL);
        instruction_t *arg = new_instruction(NULL, SW_OPCODE, 0, syscode->rdest, REG_SP, 0, NULL);
        instruction_t *sysc = new_instruction(NULL, SYSCALL_OPCODE, 0, 0, 0, 0, NULL);
        instruction_t *combined;
        combined = append_inst(syscode, arg);
        combined = append_inst(combined, sysc);
        combined = append_inst($1, combined);

        // assign to head of instruction list
        inst_list = combined;
    }
    ;

// no actions necessary, just allows for many declarations
declarations: dec declarations {
    }

    | dec {
    }
    |  {
    };

// add names to symbol table. int and string
// variables are global for now, need to
// differentiate once functions are implemented
dec: INTKEY IDENT SEMI {
        symtab_new($2, SYMTAB_INTGLOBAL);
        int *offset = (int*) malloc(sizeof(int));
        *offset = nglobals * 4;
        nglobals++;
        symtab_update($2,offset);
    }
//R: added this for string, not quite sure my malloc is correct
//R: I realize this is actually item 4 at STRKEY, I had just automatically done it when doing 2 thinking something was missing 
    | STRKEY IDENT SEMI {
        symtab_new($2, SYMTAB_STRGLOBAL);
        int *offset = (int*) malloc(sizeof(int));
        *offset = nglobals * 4;
        nglobals++;
        symtab_update($2,offset);
    }//allows for declaration & assignment @ same time, i.e. int x = 5;
    | INTKEY IDENT ASSIGN expr SEMI {
        symtab_new($2, SYMTAB_INTGLOBAL);
        int *offset = (int*) malloc(sizeof(int));
        *offset = nglobals * 4;
        nglobals++;
        symtab_update($2,offset);
        instruction_t *first = $4->list;
        instruction_t *inst = new_instruction(NULL, LI_OPCODE, vreg++, 0, 0, $4->reg, NULL);
        instruction_t *store = new_instruction(NULL, SW_OPCODE, 0, inst->rdest, REG_GP, (*offset), NULL);
        instruction_t *combined = append_inst(first, inst);
        combined = append_inst(combined, store);
        inst_list = append_inst(inst_list, combined);
        free($4);

    }//allows for declaration & assignment @ same time, i.e. string x = "HI";
    | STRKEY IDENT ASSIGN expr SEMI {
        symtab_new($2, SYMTAB_STRGLOBAL);
        int *offset = (int*) malloc(sizeof(int));
        *offset = nglobals * 4;
        nglobals++;
        symtab_update($2,offset);
        instruction_t *first = $4->list;
        instruction_t *inst = new_instruction(NULL, LI_OPCODE, vreg++, 0, 0, $4->reg, NULL);
        instruction_t *store = new_instruction(NULL, SW_OPCODE, 0, inst->rdest, REG_GP, (*offset), NULL);
        instruction_t *combined = append_inst(first, inst);
        combined = append_inst(combined, store);
        inst_list = append_inst(inst_list, combined);
        free($4);

    }
   ; 

// gather statement lists and concatenate when needed
sequence: statement sequence {
        $$ = append_inst($1,$2);
    }
    | statement {
        $$ = $1;
    };
    
    | {
        $$ = NULL;
    };
    

/*
        //allows for declaration & assignment @ same time, i.e. int x = 5;
decsign:INTKEY IDENT ASSIGN expr SEMI {
        symtab_new($2, SYMTAB_INTGLOBAL);
        int *offset = (int*) malloc(sizeof(int));
        *offset = nglobals * 4;
        nglobals++;
        symtab_update($2,offset);
        instruction_t *first = $4->list;
        instruction_t *inst = new_instruction(NULL, LI_OPCODE, vreg++, 0, 0, $4->reg, NULL);
        instruction_t *store = new_instruction(NULL, SW_OPCODE, 0, inst->rdest, REG_GP, (*offset), NULL);
        instruction_t *combined = append_inst(first, inst);
        combined = append_inst(combined, store);
        inst_list = append_inst(inst_list, combined);
        free($4);
        $$ = combined;
    }//allows for declaration & assignment @ same time, i.e. string x = "HI";
    | STRKEY IDENT ASSIGN expr SEMI {
        symtab_new($2, SYMTAB_STRGLOBAL);
        int *offset = (int*) malloc(sizeof(int));
        *offset = nglobals * 4;
        nglobals++;
        symtab_update($2,offset);
        instruction_t *first = $4->list;
        instruction_t *inst = new_instruction(NULL, LI_OPCODE, vreg++, 0, 0, $4->reg, NULL);
        instruction_t *store = new_instruction(NULL, SW_OPCODE, 0, inst->rdest, REG_GP, (*offset), NULL);
        instruction_t *combined = append_inst(first, inst);
        combined = append_inst(combined, store);
        inst_list = append_inst(inst_list, combined);
        free($4);
        $$ = combined;
    }
    | statement {
        $$ = $1;
    };
*/

// statements don't produce a value in a register, they
// are either assignments (save to memory), code blocks
// for control flow, or print system calls
statement: PUTINT LPAREN expr RPAREN SEMI {
        instruction_t *syscode = new_instruction(NULL, LI_OPCODE, vreg++, 0, 0, SYSCALL_PRINT_INT, NULL);
        instruction_t *pushsys = new_instruction(NULL, SW_OPCODE, 0, syscode->rdest, REG_SP, 0, NULL);
        instruction_t *pushval = new_instruction(NULL, SW_OPCODE, 0, $3->reg, REG_SP, -4, NULL);
        instruction_t *sysc = new_instruction(NULL, SYSCALL_OPCODE, 0, 0, 0, 0, NULL);
        instruction_t *combined;
        combined = append_inst($3->list,syscode);
        combined = append_inst(combined,pushsys);
        combined = append_inst(combined,pushval);
        combined = append_inst(combined,sysc);
        free($3);
        $$ = combined;
    }
    | dec statement {
        $$ = $2;
    }
    | PUTS LPAREN expr RPAREN SEMI {
        instruction_t *syscode = new_instruction(NULL, LI_OPCODE, vreg++, 0, 0, SYSCALL_PRINT_STRING, NULL);
        instruction_t *pushsys = new_instruction(NULL, SW_OPCODE, 0, syscode->rdest, REG_SP, 0, NULL);
        instruction_t *pushval = new_instruction(NULL, SW_OPCODE, 0, $3->reg, REG_SP, -4, NULL);
        instruction_t *sysc = new_instruction(NULL, SYSCALL_OPCODE, 0, 0, 0, 0, NULL);
        instruction_t *combined;
        combined = append_inst($3->list,syscode);
        combined = append_inst(combined,pushsys);
        combined = append_inst(combined,pushval);
        combined = append_inst(combined,sysc);
        free($3);
        $$ = combined;
    }
    | IDENT ASSIGN expr SEMI {
        int *offset = symtab_lookup($1);
        instruction_t *first = $3->list;
        instruction_t *store = new_instruction(NULL, SW_OPCODE, 0, $3->reg, REG_GP, (*offset), NULL);
        instruction_t *combined;
        combined = append_inst(first,store);
        free($3);
        $$ = combined;
    } //allows for declaration & assignment @ same time, i.e. int x = 5;
    | INTKEY IDENT ASSIGN expr SEMI {
        symtab_new($2, SYMTAB_INTGLOBAL);
        int *offset = (int*) malloc(sizeof(int));
        *offset = nglobals * 4;
        nglobals++;
        symtab_update($2,offset);
        instruction_t *first = $4->list;
        instruction_t *inst = new_instruction(NULL, LI_OPCODE, vreg++, 0, 0, $4->reg, NULL);
        instruction_t *store = new_instruction(NULL, SW_OPCODE, 0, inst->rdest, REG_GP, (*offset), NULL);
        instruction_t *combined = append_inst(first, inst);
        combined = append_inst(combined, store);
        inst_list = append_inst(inst_list, combined);
        free($4);
    }//allows for declaration & assignment @ same time, i.e. string x = "HI";
    | STRKEY IDENT ASSIGN expr SEMI {
        symtab_new($2, SYMTAB_STRGLOBAL);
        int *offset = (int*) malloc(sizeof(int));
        *offset = nglobals * 4;
        nglobals++;
        symtab_update($2,offset);
        instruction_t *first = $4->list;
        instruction_t *inst = new_instruction(NULL, LI_OPCODE, vreg++, 0, 0, $4->reg, NULL);
        instruction_t *store = new_instruction(NULL, SW_OPCODE, 0, inst->rdest, REG_GP, (*offset), NULL);
        instruction_t *combined = append_inst(first, inst);
        combined = append_inst(combined, store);
        inst_list = append_inst(inst_list, combined);
        free($4);
    }
    | IFKEY LPAREN expr RPAREN LBRACE sequence RBRACE {
         instruction_t *branch = new_instruction(NULL, BEQ_OPCODE, 0, $3->reg, REG_ZERO, 0, internal_name());
         instruction_t *target = new_instruction(branch->tgt, NOP_OPCODE, 0, 0, 0, 0, NULL);
         instruction_t *combined = append_inst($3->list, branch);
         combined = append_inst(combined, $6);
         combined = append_inst(combined, target);
         free($3);
         $$ = combined;
    }
    | IFKEY LPAREN expr RPAREN LBRACE sequence RBRACE ELSEKEY LBRACE sequence RBRACE {
        instruction_t *branch = new_instruction(NULL, BEQ_OPCODE, 0, $3->reg, REG_ZERO, 0, internal_name());
        instruction_t *target = new_instruction(branch->tgt, NOP_OPCODE, 0, 0, 0, 0, NULL);
        instruction_t *elseBranch = new_instruction(NULL, J_OPCODE, 0, 0, REG_ZERO, 0, internal_name());
        instruction_t *elseTarget = new_instruction(elseBranch->tgt, NOP_OPCODE, 0, 0, 0, 0, NULL);
        instruction_t *combined = append_inst($3->list, branch);
        combined = append_inst(combined, $6);
        combined = append_inst(combined, elseBranch);
        combined = append_inst(combined, target);
        combined = append_inst(combined, $10);
        combined = append_inst(combined, elseTarget);
        free($3);
        $$ = combined;
    };



/* T: The logical/bitwise operators (other than the logical/bw NOTs) ALL have their own preference tier relative to each other and to
    the greater OOP. Here's that order (because I am going to forget constantly while doing this):

        <=5: >>, <<, *, /, and so on

        6: <, <=, >, >=
        7: ==, !=
        8: & [bitwise AND]
        9: ^ [bitwise XOR]
        10: | [bitwise OR]
        11: && [logic AND]
        12: || [logic OR]

        >=13: =, +=, -=, and so on

*/

// expressions, terms, and factors will have sequences of
// instructions that produce a value in a register, thus
// use an expr_result_t to pass up to statements
// --------
//R: adding other logic and bitwise for item 3
expr: expr LOGICOR logicand {
	instruction_t *first = $1->list;
        instruction_t *second = $3->list;
        instruction_t *x_inst = new_instruction(NULL, SNEI_OPCODE, vreg++, $1->reg, 0, 0, NULL);
        instruction_t *y_inst = new_instruction(NULL, SNEI_OPCODE, vreg++, $3->reg, 0, 0, NULL);
        instruction_t *lor_inst = new_instruction(NULL, OR_OPCODE, vreg++, x_inst->rdest, y_inst->rdest, 0, NULL);

        instruction_t *combined = NULL;
        combined = append_inst(combined, first);
        combined = append_inst(combined, second);
        combined = append_inst(combined, x_inst);
        combined = append_inst(combined, y_inst);
        combined = append_inst(combined, lor_inst);

        //check
        free($1);
        free($3);
        $$ = new_expr_result(lor_inst->rdest, combined, EXPR_INT);
    }
    |logicand {
        $$ = $1;
    }
;
logicand: logicand LOGICAND bitor {
    	instruction_t *first = $1->list;
        instruction_t *second = $3->list;
        instruction_t *x_inst = new_instruction(NULL, SNEI_OPCODE, vreg++, $1->reg, 0, 0, NULL);
        instruction_t *y_inst = new_instruction(NULL, SNEI_OPCODE, vreg++, $3->reg, 0, 0, NULL);
        instruction_t *land_inst = new_instruction(NULL, AND_OPCODE, vreg++, x_inst->rdest, y_inst->rdest, 0, NULL);
        instruction_t *combined = NULL;
        combined = append_inst(combined, first);
        combined = append_inst(combined, second);
        combined = append_inst(combined, x_inst);
        combined = append_inst(combined, y_inst);
        combined = append_inst(combined, land_inst);

        //check
        free($1);
        free($3);
        $$ = new_expr_result(land_inst->rdest, combined, EXPR_INT);

    }
    |bitor {
        $$ = $1;
    }
;
bitor: bitor OR bitxo {
	instruction_t *first = $1->list;
        instruction_t *second = $3->list;
        instruction_t *bor_inst = new_instruction(NULL, OR_OPCODE, vreg++, $1->reg, $3->reg, 0, NULL);
        instruction_t *combined = NULL;
        combined = append_inst(combined, first);
        combined = append_inst(combined, second);
        combined = append_inst(combined, bor_inst);

        //check
        free($1);
        free($3);
        $$ = new_expr_result(bor_inst->rdest, combined, EXPR_INT);
    }
    |bitxo {
        $$ = $1;
    };

bitxo: bitxo XOR bitand{
        instruction_t *first = $1->list;
        instruction_t *second = $3->list;
        instruction_t *x_inst = new_instruction(NULL, XOR_OPCODE, vreg++, $1->reg, $3->reg, 0, NULL);
        instruction_t *combined = NULL;
        combined = append_inst(combined, first);
        combined = append_inst(combined, second);
        combined = append_inst(combined, x_inst);

	//check
        free($1);
        free($3);
        $$ = new_expr_result(x_inst->rdest, combined, EXPR_INT);

    }
    |bitand {
        $$ = $1;
    };

bitand: bitand AND lequal{
        instruction_t *first = $1->list;
        instruction_t *second = $3->list;
        instruction_t *band_inst = new_instruction(NULL, AND_OPCODE, vreg++, $1->reg, $3->reg, 0, NULL);
        instruction_t *combined = NULL;
        combined = append_inst(combined, first);
        combined = append_inst(combined, second);
        combined = append_inst(combined, band_inst);
	
        free($1);
        free($3);
        $$ = new_expr_result(band_inst->rdest, combined, EXPR_INT);
    }
    |lequal{
        $$ = $1;
    };

lequal: lequal EQ compare {
        instruction_t* first = $1->list;
        instruction_t* second = $3->list;
        instruction_t* eq_inst = new_instruction(NULL, SEQ_OPCODE, vreg++, $1->reg, $3->reg, 0, NULL);
	instruction_t *combined = NULL;
        combined = append_inst(combined, first);
        combined = append_inst(combined, second);
        combined = append_inst(combined, eq_inst);
        
	free($1);
        free($3);
        $$ = new_expr_result(eq_inst->rdest, combined, EXPR_INT);
    }

    |lequal NEQ compare{
        instruction_t* first = $1->list;
        instruction_t* second = $3->list;
        instruction_t* neq_inst = new_instruction(NULL, SEQ_OPCODE, vreg++, $1->reg, $3->reg, 0, NULL);
        instruction_t *combined = NULL;
        combined = append_inst(combined, first);
        combined = append_inst(combined, second);
        combined = append_inst(combined, neq_inst);
	
	//check
	free($1);
        free($3);
        $$ = new_expr_result(neq_inst->rdest, combined, EXPR_INT);
    }
    | compare {
        $$ = $1;
    };

compare: compare LT shift {
       	instruction_t *first = $1->list;
        instruction_t *second = $3->list;
        instruction_t *lt_inst = new_instruction(NULL, SLT_OPCODE, vreg++, $1->reg, $3->reg, 0, NULL);
	instruction_t *combined = NULL;
        combined = append_inst(combined, first);
        combined = append_inst(combined, second);
        combined = append_inst(combined, lt_inst);
	
	//check type
        free($1);
        free($3);
        $$ = new_expr_result(lt_inst->rdest, combined, EXPR_INT);
    }
    |compare GT shift {
        instruction_t *first = $1->list;
        instruction_t *second = $3->list;
        instruction_t *gt_inst = new_instruction(NULL, SGT_OPCODE, vreg++, $1->reg, $3->reg, 0, NULL);
        instruction_t *combined = NULL;
        combined = append_inst(combined, first);
        combined = append_inst(combined, second);
        combined = append_inst(combined, gt_inst);
	
	//check teype
        free($1);
        free($3);
        $$ = new_expr_result(gt_inst->rdest, combined, EXPR_INT);
    }
    |compare LTE shift {
        instruction_t *first = $1->list;
        instruction_t *second = $3->list;
        instruction_t *lte_inst = new_instruction(NULL, SLTE_OPCODE, vreg++, $1->reg, $3->reg, 0, NULL);
        instruction_t *combined = NULL;
        combined = append_inst(combined, first);
        combined = append_inst(combined, second);
        combined = append_inst(combined, lte_inst);

	//check type
        free($1);
        free($3);
        $$ = new_expr_result(lte_inst->rdest, combined, EXPR_INT);
    }
    |compare GTE shift {
        instruction_t *first = $1->list;
        instruction_t *second = $3->list;
        instruction_t *gte_inst = new_instruction(NULL, SGTE_OPCODE, vreg++, $1->reg, $3->reg, 0, NULL);
        instruction_t *combined = NULL;
        combined = append_inst(combined, first);
        combined = append_inst(combined, second);
        combined = append_inst(combined, gte_inst);

	//check type
        free($1);
        free($3);
        $$ = new_expr_result(gte_inst->rdest, combined, EXPR_INT);
    }
    | shift {
        $$ = $1;
    };
shift: shift LSHIFT plusminus {
     	instruction_t *first = $1->list;
        instruction_t *second = $3->list;
        instruction_t *sll_inst = new_instruction(NULL, SLL_OPCODE, vreg++, $1->reg, $3->reg, 0, NULL);
        instruction_t *combined = NULL;
        combined = append_inst(combined, first);
        combined = append_inst(combined, second);
        combined = append_inst(combined, sll_inst);

        //check type
        free($1);
        free($3);
        $$ = new_expr_result(sll_inst->rdest, combined, EXPR_INT);
    }
    |shift RSHIFT plusminus {
       	instruction_t *first = $1->list;
        instruction_t *second = $3->list;
        instruction_t *srl_inst = new_instruction(NULL, SRL_OPCODE, vreg++, $1->reg, $3->reg, 0, NULL);
        instruction_t *combined = NULL;
        combined = append_inst(combined, first);
        combined = append_inst(combined, second);
        combined = append_inst(combined, srl_inst);

	//check type
        free($1);
        free($3);
        $$ = new_expr_result(srl_inst->rdest, combined, EXPR_INT); 
    }
    | plusminus {
        $$ = $1;
    };

plusminus: plusminus PLUS term {
        instruction_t *first = $1->list;
        instruction_t *second = $3->list;
        instruction_t *add_inst = new_instruction(NULL, ADD_OPCODE, vreg++, $1->reg, $3->reg, 0, NULL);
        instruction_t *combined = NULL;
	combined = append_inst(combined, first);
        combined = append_inst(combined, second);
        combined = append_inst(combined, add_inst);
	//check
        free($1);
        free($3);
        $$ = new_expr_result(add_inst->rdest, combined, EXPR_INT);
    }//R: add minus
    |expr MINUS term {
        instruction_t *first = $1->list;
        instruction_t *second = $3->list;
        instruction_t *m_inst = new_instruction(NULL, SUB_OPCODE, vreg++, $1->reg, $3->reg, 0, NULL);
        instruction_t *combined = NULL;
        combined = append_inst(combined, first);
        combined = append_inst(combined, second);
        combined = append_inst(combined, m_inst);
	//check
        free($1);
        free($3);
        $$ = new_expr_result(m_inst->rdest, combined, EXPR_INT);
    }
    | term {
        $$ = $1;
    };

// higher in precedence than expr
term: term MULTIPLY factor {
        instruction_t *first = $1->list;
        instruction_t *second = $3->list;
        instruction_t *mult_inst = new_instruction(NULL, MULT_OPCODE, vreg++, $1->reg, $3->reg, 0, NULL);
        instruction_t *combined = NULL;
        combined = append_inst(combined, first);
        combined = append_inst(combined, second);
        combined = append_inst(combined, mult_inst);
	//check
        free($1);
        free($3);
        $$ = new_expr_result(mult_inst->rdest, combined, EXPR_INT);
    }//R: add divide
    |term DIVIDE factor {
        instruction_t *first = $1->list;
        instruction_t *second = $3->list;
        instruction_t *d_inst = new_instruction(NULL, DIV_OPCODE, vreg++, $1->reg, $3->reg, 0, NULL);
        instruction_t *combined = NULL;
        combined = append_inst(combined, first);
        combined = append_inst(combined, second);
        combined = append_inst(combined, d_inst);

        free($1);
        free($3);
        $$ = new_expr_result(d_inst->rdest, combined, EXPR_INT);
    }
    | nott {
        $$ = $1;
    };

nott: NOT factor{
    	instruction_t *first = $2->list;
        instruction_t *bnot_inst = new_instruction(NULL, NOT_OPCODE, vreg++, $2->reg, 0, 0, NULL);
        instruction_t *combined = NULL;
        combined = append_inst(combined, first);
        combined = append_inst(combined, bnot_inst);

	//type check here
        free($2);
        $$ = new_expr_result(bnot_inst->rdest, combined, EXPR_INT);
    }
    |LOGICNOT factor{
    	instruction_t *first = $2->list;
        instruction_t *ln_inst = new_instruction(NULL, SEQ_OPCODE, vreg++, $2->reg, REG_ZERO, 0, NULL);
        instruction_t *combined = NULL;
        combined = append_inst(combined, first);
        combined = append_inst(combined, ln_inst);

        //type check
        free($2);
        $$ = new_expr_result(ln_inst->rdest, combined, EXPR_INT);
    }
    |factor{
        $$ = $1;
    };

// higher in precedence than term
factor: INTLIT {
        instruction_t * inst = new_instruction(NULL, LI_OPCODE, vreg++, 0, 0, $1, NULL);
        $$ = new_expr_result(inst->rdest, inst, EXPR_INT);
    }
    | STRINGLIT {
        mem_entry_t *data = new_mem_entry(internal_name(),$1);
        instruction_t *inst = new_instruction(NULL, LA_OPCODE, vreg++, 0, 0, 0, data->label);
        insert_data(data);
        $$ = new_expr_result(inst->rdest, inst, EXPR_STRING);
    }
    | IDENT {
        int *offset = symtab_lookup($1);
        instruction_t * inst = new_instruction(NULL, LW_OPCODE, vreg++, REG_GP, 0, (*offset), NULL);
        $$ = new_expr_result(inst->rdest, inst, EXPR_INT);
    }
    | GETINT LPAREN RPAREN {
        instruction_t *syscode = new_instruction(NULL, LI_OPCODE, vreg++, 0, 0, SYSCALL_READ_INT, NULL);
        instruction_t *pushsys = new_instruction(NULL, SW_OPCODE, 0, syscode->rdest, REG_SP, 0, NULL);
        instruction_t *syscall = new_instruction(NULL, SYSCALL_OPCODE, 0, 0, 0, 0, NULL);
        instruction_t *move = new_instruction(NULL, ADDI_OPCODE, vreg++, REG_V0, 0, 0, NULL);
        instruction_t *combined;
        combined = append_inst(syscode, pushsys);
        combined = append_inst(combined, syscall);
        combined = append_inst(combined, move);

        $$ = new_expr_result(move->rdest, combined, EXPR_INT);
    } // T: added this to enforce oop (i.e. something like 7 / (6 + 4))
    | LPAREN expr RPAREN {
        $$ = $2;
    };


%%

int yydebug = 1;
char * current_file = NULL;

// the cheesiest main function evar!
int main(int argc, char *argv[]){
    FILE *fd;
    yylineno = -1;
    if (argc == 2) {
        current_file = strdup(argv[1]);
        // open the input program file
        fd = fopen(current_file,"r");
        // and parse that dawg
        if (fd){
            yyrestart(fd);
            yylineno = 1;
            yyparse();
        }
        else{
            yyerror("Could not open input program file");
        }
        fclose(fd);
    }
    else {
        yyerror("Input program file name must be passed at the command-line");
    }

    dump_symtab();

    // got super lazy, and hard-coded the output assembly file
    //  normally gcc writes a default a.out... but since this
    //  output will be assembly, it's a.s... get it?
    write_asm("a.s");

    return EXIT_SUCCESS;
}

// definition of yyerror, needed by auto-generated parser code
int yyerror(const char *s){
    fprintf(stderr, "error: %s\n\tfile: %s\tline: %d\n", s, current_file, yylineno);
    exit(EXIT_FAILURE);
}
