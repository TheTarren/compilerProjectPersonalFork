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
    /* scanner.l                                                                  */
    /* The regular expressions for all of the bits and bobs for the cc442         */
    /* scanner.                                                                   */
    /******************************************************************************/

%option noyywrap yylineno

%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "parser.tab.h"
#include "tnmarch.h"
%}

%%

    /* Operators */
\+                               {return PLUS;}
-                                {return MINUS;}
\*                               {return MULTIPLY;}
\/                               {return DIVIDE;}
&                                {return AND;}
\|                               {return OR;}
~                                {return NOT;}
\^                               {return XOR;}
\<\<                             {return LSHIFT;}
\>\>                             {return RSHIFT;}
\<                               {return LT;}
\>                               {return GT;}
\<=                              {return LTE;}
\>=                              {return GTE;}

!                                {return LOGICNOT;} 
&&                               {return LOGICAND;}
\|\|                             {return LOGICOR;}

==                               {return EQ;}
!=                               {return NEQ;}
=                                {return ASSIGN;}

    /* Code Blocks */
if                               {return IFKEY;}
else                             {return ELSEKEY;}
while                            {return WHILEKEY;}

    /* Types */
int                              {return INTKEY;}
string                           {return STRKEY;}

    /* Syscalls */
exit                             {return EXIT;}
putint                           {return PUTINT;}
puts                             {return PUTS;}
getint                           {return GETINT;}
gets                             {return GETS;}
malloc                           {return MALLOC;}

    /* Literals */
[0-9]+                           {yylval.ivalue = atoi(yytext); return INTLIT;}
0x[0-9a-f]+                      {sscanf(yytext,"%x",&(yylval.ivalue)); return INTLIT;}
\".*\"                           {yylval.string = strndup(&yytext[1],strlen(yytext)-2); return STRINGLIT;} 


    /* Comments */
\/\/.*                           /* no action, just gobble up comments */

    /* Identifiers */
[a-zA-Z][a-zA-Z0-9_]*            {yylval.string = strdup(yytext);return IDENT;}

    /* Delimiter kinds of things */
\[                               {return LBRACKET;}
\]                               {return RBRACKET;}
\{                               {return LBRACE;}
\}                               {return RBRACE;}
\(                               {return LPAREN;}
\)                               {return RPAREN;}
:                                {return COLON;}
,                                {return COMMA;}
;                                {return SEMI;}

    /* Misc */
[ \t]+                           /* whitespace -- do nothing */
[\n\r]+                          /* linefeed -- do nothing */
.                                {return UNKNOWN;} // catch-all for anything else

%%

