//testing item 3
//Bitwise AND (&) example
int num1; 
num1 = 14;
int num2; 
num2 = 7;
int result_and = num1 & num2;
putint(result_and);

//Bitwise OR (|) example
int result_or; 
result_or = num1 | num2; // binary: 1111 (decimal: 15)
putint(result_or);

// Bitwise XOR (^) example
int result_xor; 
result_xor = num1 ^ num2; // binary: 1001 (decimal: 9)
putint(result_xor);

// Bitwise NOT (~) example
int result_not;
result_not = ~num1; // binary: 1110 (two's complement) (decimal: -15)
putint(result_not);

// Logical AND (&&) example
int condition1;
condition1 = 1;
int condition2;
condition2 = 0;
result_and = condition1 && condition2;
putint(result_and);

// Logical OR (||) example
result_or = condition1 || condition2;
putint(result_or);

// Logical NOT (!) example
int condition3;
condition3 = 0;
result_not = !condition3;
putint(result_not);
