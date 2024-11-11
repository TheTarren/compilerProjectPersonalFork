// This is a "C" program to be used as an example 
// input program to the cc442 compiler. This will 
// obviously not compile with gcc. 
//
// This test should compile with cc442 and simulate 
// on Simmy McSimface just fine, as long as your 
// symbol table and append_inst() function correctly.
// T: Added to test new integer operators added by item 2
// Needs to test: Divide, Parenthesis (i.e. OOP enforcement), Minus

int w; 
int x;
int y;
int z;
w = 7 / 2;
putint(w);
x = 7 / (2 * 3);
putint(x);
y = 6 / (4 + 2);
putint(y);
z = 6 * 4;
putint(z);

//ALL WORKS!!!!!!

