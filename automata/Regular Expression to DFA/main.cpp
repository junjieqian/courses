#include "DFA.h"
#include "DFA.cpp"
#include "Adjtable.h"
#include "Adjtable.cpp"
#include "TTable.h"
#include "TTable.cpp"
#include "LinkedStack.h"
#include "LinkedStack.cpp"
#include "EdgeVertex.h"
#include "EdgeVertex.cpp"
#include <iostream>
#include <fstream>
#include <string>

using namespace std;

//extern char *exp;
//extern char WordBuffer;

// main function
// void main()
int main()
{
	DFA dfa;
    dfa.GetRegExp();
	dfa.InsertCatNode();
	dfa.RegExpToPost();
	dfa.GetEdgeNumber();
	dfa.ThompsonConstruction();
	dfa.SubsetConstruction();
	dfa.check();
        return 0;
}

