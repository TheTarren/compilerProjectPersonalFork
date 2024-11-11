// This is a "C" program to be used as an example 
// input program to the cc442 compiler. This will 
// obviously not compile with gcc. 
//
// This program should fail to compile, since 
// bar was never declared

int foo;
foo = bar + 1;
putint(foo);
