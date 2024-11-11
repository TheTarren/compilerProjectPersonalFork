// This is a "C" program to be used as an example 
// input program to the cc442 compiler. This will 
// obviously not compile with gcc. 
//
// This test should compile with cc442 and simulate 
// on Simmy McSimface just fine, as long as your 
// symbol table and append_inst() function correctly.
// T: Added to test new logical operators added by item 3
// Needs to test: Logic AND, Logic OR, Logic NOT


int q;
int r;
int s;
int t;
int u;
int v;
int w;
int x;
int y;
int z;
q = 0 && 0;
putint(q);
r = 0 && 1;
putint(r);
s = 1 && 0;
putint(s);
t = 1 && 1;
putint(t);
u = 0 || 0;
putint(u);
v = 0 || 1;
putint(v);
w = 1 || 0;
putint(w);
x = 1 || 1;
putint(x);
y = !0;
putint(y);
z = !1;
putint(z);
