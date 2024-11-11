// This is a "C" program to be used as an example 
// input program to the cc442 compiler. This will 
// obviously not compile with gcc. 
//
// This test should compile with cc442 and simulate 
// on Simmy McSimface just fine, as long as your 
// symbol table and append_inst() function correctly.
int x;
int y;
x = 7;
y = 3 + x * getint() + 1;
putint(y + 1);
