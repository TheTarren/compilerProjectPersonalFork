// This is a "C" program to be used as an example 
// input program to the cc442 compiler. This will 
// obviously not compile with gcc. 
//
// This test should compile with cc442 and simulate 
// on Simmy McSimface just fine, as long as your 
// symbol table and append_inst() function correctly.
// T: Added to test new integer operators added by item 2
// Needs to test: Bitwise AND, BW OR, BW NOT, BW XOR

int w;
int x;
int y;
int z;
w = 15 & 1; //should be 1 (1111 & 0001)
putint(w);
x = 10 | 5; //should be 15 (1010 & 0101)
putint(x);
y = ~15; //should be 0 (~1111)
putint(y);
z = 15 ^ 10; //should be 5 (1111 ^ 1010)
putint(z);