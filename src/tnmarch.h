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
/* tnmarch.h                                                                  */
/* Defines constants for the TNM instruction set                              */
/*                                                                            */
/******************************************************************************/

#ifndef _TNMARCH_H_
#define _TNMARCH_H_

/* defines for each instruction mnemonic - opcodes are unique, 
 * but arbitrarily chosen, non-zero, values */
#define ADD_OPCODE          0x01
#define AND_OPCODE          0x02
#define RET_OPCODE          0x03
#define NOT_OPCODE          0x04
#define XOR_OPCODE          0x05
#define OR_OPCODE           0x06
#define SLT_OPCODE          0x07
#define SGT_OPCODE          0x08
#define SLTE_OPCODE         0x09
#define SGTE_OPCODE         0x0a
#define SLL_OPCODE          0x0b
#define SRL_OPCODE          0x0c
#define SUB_OPCODE          0x0d
#define DIV_OPCODE          0x0e
#define MULT_OPCODE         0x0f
#define SRA_OPCODE          0x10
#define SYSCALL_OPCODE      0x11
#define ADDI_OPCODE         0x12
#define ANDI_OPCODE         0x13
#define BEQ_OPCODE          0x14
#define BNE_OPCODE          0x15
#define LB_OPCODE           0x16
#define LI_OPCODE           0x17
#define LW_OPCODE           0x18
#define ORI_OPCODE          0x19
#define SLTI_OPCODE         0x1a
#define SGTI_OPCODE         0x1b
#define SLTEI_OPCODE        0x1c
#define SGTEI_OPCODE        0x1d
#define SEQ_OPCODE          0x1e
#define SEQI_OPCODE         0x1f
#define SNE_OPCODE          0x20
#define SNEI_OPCODE         0x21
#define SB_OPCODE           0x22
#define SW_OPCODE           0x23
#define J_OPCODE            0x24
#define JAL_OPCODE          0x25
#define LA_OPCODE           0x26
#define NOP_OPCODE          0x27

// the only architected registers in TNM 
#define REG_ZERO            0
#define REG_SP              1
#define REG_FP              2
#define REG_GP              3
#define REG_RA              4
#define REG_V0              5

// syscall codes
#define SYSCALL_PRINT_INT    1
#define SYSCALL_PRINT_STRING 2
#define SYSCALL_READ_INT     3
#define SYSCALL_READ_STRING  4
#define SYSCALL_SBRK         5
#define SYSCALL_EXIT         6
#define SYSCALL_PRINT_CHAR   7  // not needed for CS 442
#define SYSCALL_READ_CHAR    8  // not needed for CS 442

#endif
