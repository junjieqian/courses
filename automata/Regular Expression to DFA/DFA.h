#ifndef DFA_H
#define DFA_H
#include "TTable.h"
#include "Adjtable.h"
#include "LinkedStack.h"

#include <string>
using namespace std;

// Define the class of DFA
class DFA
{
public:
	DFA();
	~DFA();
	void GetRegExp();
	void InsertCatNode();
	void RegExpToPost();
	void GetEdgeNumber();
	void ThompsonConstruction();
	void SubsetConstruction();
	void check();                        //check whether the strings are accepted
private:
	char *exp;
	char *post;
	char *edge;
	char WordBuffer[1024];            //store the strings
	string filename;
	int edgeNumber;
	int **DStates;
	int **Dtran;
	int **Move;                       //minimize the DFA transmission states
	int *AcceptStates;
	int DStatesNumber;
	int DtranNumber;
	int NFAStatesNumber;
	int DFAStatesNumber;
	int FinalState;                  //store the final state
	int r,l;
	AdjacentTable *NFATable;
	TransitionTable *DFATable;
	int Precedence(char symbol);
	int CompArray(int *t1, int *t2);
	int MinimizeDFAStates(int **Dtran, int *AcceptStates, int DtranNumber, int edgeNumber);
};
#endif