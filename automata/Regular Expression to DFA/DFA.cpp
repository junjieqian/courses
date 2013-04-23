#include "DFA.h"
#include <iostream>
#include <fstream>
#include <stdio.h>
#include <stdlib.h>
// linux c++ doesnot have the conio library
// #include <conio.h>
#include <cstring>

using namespace std;


// constructor, construct the function
DFA::DFA()
{
	exp = new char[128];
	post = new char[128];
	edge = new char[128];
        edgeNumber = 0;
	NFAStatesNumber = 0;
	DFAStatesNumber = 0;
	DStatesNumber = 0;
	DtranNumber = 0;
	NFATable = new AdjacentTable();
}

// destructor, destruct the function
DFA::~DFA()
{
	delete [] exp;
	delete [] post;
	delete [] edge;
	delete [] AcceptStates;
	NFATable->Clear();
	DFATable->Clear();
}


//obtain the input regular expression in the txt
 void DFA::GetRegExp()
{
	//cout << "Please input Regular Expression:" << endl;
	//cin >> exp;
	// for (int i=0; exp[i]!='\0'; i++)
	// {
	//	if (exp[i] == '$')
	//	{
	//		cout << "\nsymbol '$'has been forbidden£¡" << endl;
	//		getch();
	//		exit(1);
	//	}
	//}
	// string filename;
	cout << "PLEASE INPUT THE TEST FILE NAME:" << endl;
	cin >> filename;

	ifstream fin(filename.c_str());
        
	const int LINE_LENGTH = 1000; 
 
	fin.getline(exp,LINE_LENGTH);

	// cout << "Regular Expression is :" << exp << endl;
}

//obtain strings in the txt
/* void DFA::GetStrings()
{
	ifstream fin(filename);
	char *checkstrings;
	while(fin.getline(checkstrings,1024) )
	{
	 int i=0;
	 while(WordBuffer[i-1]!='\n')
	 {
		WordBuffer[i] = *checkstrings;
		i++;
	 }
	}
}*/

// insert cat-node as the "and" sign
void DFA::InsertCatNode()
{
	int i = 0, j, len = strlen(exp);
	while (exp[i+1] != '\0')
	{
		if (((exp[i] != '(' && exp[i] != '.' && exp[i] != '|') 
			|| exp[i] == ')' 
			|| exp[i] == '*')
			&& (exp[i+1] != ')' && exp[i+1] != '.' && exp[i+1] != '|' && exp[i+1] != '*'))
		{
			for (j=len; j>i+1; j--)
			{
				exp[j] = exp[j-1];
			}
			exp[i+1] = '.';
			len++;
			exp[len] = '\0';
			i++;
		}
		i++;
	}
	//cout << "\nadd the and operation to RE:\n"
	//	 << exp << "\n";
}

// define the precedence of operations
int DFA::Precedence(char symbol)
{
	int priority;
	switch (symbol)
	{
	case '|': priority = 1; break;
	case '.': priority = 2; break;
	case '*': priority = 3; break;
	default:  priority = 0; break;
	}
	return priority;
}

// transfer the RE to postfix
void DFA::RegExpToPost()
{
	int i = 0, j = 0;
	char ch, cl;
	strcpy(post, "\0");
	LinkedStack<char> *ls = new LinkedStack<char>();
	ls->makeEmpty();
	ls->Push('#');
	ch = exp[i];
	while (ch != '\0')
	{
		if (ch == '(')
		{
			ls->Push(ch);
			ch = exp[++i];
		}
		else if (ch == ')')
		{
			while (ls->getTop() != '(')
			{
				post[j++] = ls->Pop();
			}
            ls->Pop();
			ch = exp[++i];
		}
		else if ((ch == '|') || (ch == '*') || (ch == '.'))
		{
	    	cl = ls->getTop();
		   	while (Precedence(cl) >= Precedence(ch))
			{
		    	post[j++] = cl;
		    	ls->Pop();
		    	cl = ls->getTop();
			}
			ls->Push(ch);
			ch = exp[++i];
		}
		else
		{
			post[j++] = ch;
			ch = exp[++i];
		}
	}
	ch = ls->Pop();
	while ((ch == '|') || (ch == '*') || (ch == '.'))
	{
		post[j++] = ch;
		ch = ls->Pop();
	}
	post[j] = '\0';
	ls->makeEmpty();
}

// scan the postfix to get edge number
void DFA::GetEdgeNumber()
{
	int i = 0, j;
	edgeNumber = 0;
	while (post[i] != '\0')
	{
		if (post[i] == '.' || post[i] == '|' || post[i] == '*')
		{
			i++;
			continue;
		}
		for (j=0; j<edgeNumber; j++)
		{
			if (post[i] == edge[j])
			{
				break;
			}
		}
		if (j == edgeNumber)
		{
			edge[edgeNumber] = post[i];
			edgeNumber++;
		}
		i++;
	}
	edge[edgeNumber] = '\0';
	// cout << "\noutput the symbols:\n";
	/*for (i=0; i<edgeNumber; i++)
	{
		cout << edge[i] << ' ';
	}*/
	// cout << "\nnumber of symbols: " << edgeNumber<< endl;
}

// construct the NFA with Thompson algorithm
void DFA::ThompsonConstruction()
{
	int i, j;
	char ch;
	int s1, s2;
	LinkedStack<int> *states = new LinkedStack<int>();
	states->makeEmpty();
	/*if (strlen(post) < 1)
	{
		cout << "No Valid Regular Expression Found!" << endl;
		getch();
		exit(1);
	}*/
	NFATable->SetValue(0, 0);
	i = 1;
	j = 0;
	ch = post[j];
    while (ch != '\0')
	{
		if (ch == '.')
		{
			s2 = states->Pop();
			int temp1 = states->Pop();
			int temp2 = states->Pop();
			s1 = states->Pop();
			NFATable->InsertEdgeByValue(temp2, temp1, '$');
			states->Push(s1);
			states->Push(s2);
		}
		else if (ch == '|')
		{
			s2 = states->Pop();
			int temp1 = states->Pop();
			int temp2 = states->Pop();
			s1 = states->Pop();
			NFATable->InsertVertex(i);
			NFATable->InsertVertex(i+1);
			NFATable->InsertEdgeByValue(i, s1, '$');
			NFATable->InsertEdgeByValue(i, temp1, '$');
			NFATable->InsertEdgeByValue(temp2, i+1, '$');
			NFATable->InsertEdgeByValue(s2, i+1, '$');
			s1 = i;
			s2 = i+1;
			states->Push(s1);
			states->Push(s2);
			i += 2;
		}
		else if (ch == '*')
		{
			s2 = states->Pop();
			s1 = states->Pop();
			NFATable->InsertVertex(i);
			NFATable->InsertVertex(i+1);
			NFATable->InsertEdgeByValue(i, i+1, '$');
			NFATable->InsertEdgeByValue(s2, s1, '$');
			NFATable->InsertEdgeByValue(i, s1, '$');
			NFATable->InsertEdgeByValue(s2, i+1, '$');
			s1 = i;
			s2 = i+1;
			states->Push(s1);
			states->Push(s2);
			i += 2;
		}
		else
		{
			NFATable->InsertVertex(i);
			NFATable->InsertVertex(i+1);
			NFATable->InsertEdgeByValue(i, i+1, ch);
			s1 = i;
			s2 = i+1;
			states->Push(s1);
			states->Push(s2);
			i += 2;
		}
		j++;
		ch = post[j];
	}
	s2 = states->Pop();
	s1 = states->Pop();
	NFATable->InsertEdgeByValue(0, s1, '$');
	/*if (! states->IsEmpty())
	{
		cout << "Some error in your input string!" << endl;
		getch();
		exit(1);
	}*/
	NFAStatesNumber = s2 + 1;
}

// compare two arrays to see whether they have same elements
int DFA::CompArray(int *t1, int *t2)
{
	int i = 0, j = 0, len1, len2;
	while (t1[i] != -1)
	{
		i++;
	}
	len1 = i;
	while (t2[j] != -1)
	{
		j++;
	}
	len2 = j;
	if (len1 != len2)
	{
		return 0;
	}
	for (i=0; i<len1; i++)
	{
		for (j=0; j<len2; j++)
		{
			if (t1[i] == t2[j])
			{
				break;
			}
		}
		if (j == len2)
		{
			return 0;
		}
	}
	return 1;
}

// minimize the Dtran
int DFA::MinimizeDFAStates(int **Dtran, int *AcceptStates, int DtranNumber, int edgeNumber)
{
	int h, i, j, k, l;
	for (i=0; i<DtranNumber-1; i++)
	{
		for (j=i+1; j<DtranNumber; j++)
		{
			if (AcceptStates[i] == AcceptStates[j])
			{
				for (k=0; k<edgeNumber; k++)
				{
					if (Dtran[i][k] != Dtran[j][k])
					{
						break;
					}
				}
				if (k == edgeNumber)
				{
					for (l=j; l<DtranNumber-1; l++)
					{
						for (k=0; k<edgeNumber; k++)
						{
							Dtran[l][k] = Dtran[l+1][k];
						}
						AcceptStates[l] = AcceptStates[l+1];
					}
					for (l=0; l<DtranNumber-1; l++)
					{
						for (k=0; k<edgeNumber; k++)
						{
							if (Dtran[l][k] == j)
							{
								Dtran[l][k] = i;
							}
						}
					}
					for (h=j; h<DtranNumber; h++)
					{
						for (l=0; l<DtranNumber-1; l++)
						{
							for (k=0; k<edgeNumber; k++)
							{
								if (Dtran[l][k] == h+1)
								{
									Dtran[l][k] = h;
								}
							}
						}
					}
					DtranNumber--;
					j--;
				}
			}
		}
	}
	return DtranNumber;
}

// construct DFA with subset
void DFA::SubsetConstruction()
{
	int i, j, k;
	DStatesNumber = 0;
	DtranNumber = 0;

	// output NFA states table
	// cout << "\noutput NFA states table with Epslion($ is Epslion):\n\n";
    // NFATable->OutputNFA();
	// cout << endl;
	// initial Dstates and Dtran and AcceptStates array
	DStates = (int**)(new int*[NFAStatesNumber+1]);
	for (i=0; i<NFAStatesNumber+1; i++)
	{
		DStates[i] = new int[NFAStatesNumber+1];
	}
	Dtran = (int**)(new int*[NFAStatesNumber+1]);
	for (i=0; i<NFAStatesNumber+1; i++)
	{
		Dtran[i] = new int[edgeNumber+1];
	}
	for (i=0; i<NFAStatesNumber+1; i++)
	{
		for (j=0; j<edgeNumber+1; j++)
		{
			Dtran[i][j] = -1;
		}
	}
	AcceptStates = new int[NFAStatesNumber+1];
	for (i=0; i<NFAStatesNumber+1; i++)
	{
		AcceptStates[i] = 0;
	}

	// construct Dstates and Dtran with closure and move
    int *T = new int[NFAStatesNumber+1];
	int *temp = new int[NFAStatesNumber+1];
	T[0] = 0;
	T[1] = -1;
	T = NFATable->Closure(T);
	DStates[DStatesNumber] = T;
	DStatesNumber++;
	k = 0;
	while (k < DStatesNumber)
	{
		for (i=0; edge[i]!='\0'; i++)
		{
			temp = NFATable->Closure(NFATable->Move(T, edge[i]));
			if (temp[0] != -1)
			{
				for (j=0; j<DStatesNumber; j++)
				{
					if (CompArray(temp, DStates[j]) == 1)
					{
						Dtran[k][i] = j;
						break;
					}
				}
				if (j == DStatesNumber)
				{
					DStates[DStatesNumber] = temp;
					Dtran[k][i] = DStatesNumber;
					DStatesNumber++;
				}
			}
		}
		k++;
		T = DStates[k];
	}
	DtranNumber = k;
	for (i=0; i<DStatesNumber; i++)
	{
		for (j=0; DStates[i][j]!= -1; j++)
		{
			if (DStates[i][j] == NFAStatesNumber - 1)
			{
				AcceptStates[i] = 1;
				break;
			}
		}
	}

	// output the DStates table
	/*cout << "\noutput Epsilon-closure:\n\n";
	for (i=0; i<DStatesNumber; i++)
	{
		cout << "states" << i <<":  ";
		j = 0;
		while (DStates[i][j] != -1)
		{
			cout << DStates[i][j] << " ";
			j++;
		}
		cout << endl;
	}*/

	// output Dtran table
	// cout << "\noutput DFA transmission table:\n\nstates ";
	/*for (j=0; j<edgeNumber; j++)
	{
		cout << "    " << edge[j];
	}
	cout<<endl;
	for (i=0; i<DtranNumber; i++)
	{
		if (i < 10)  cout << "   " << i << " ";
		else if (i < 100)  cout << "  " << i << " ";
		else if (i < 1000)  cout << " " << i << " ";
		else  cout << i << " ";
		for (j=0; j<edgeNumber; j++)
		{
			if (Dtran[i][j] < 0)  cout << "     ";
			else if (Dtran[i][j] < 10)  cout << "    " << Dtran[i][j];
			else if (Dtran[i][j] < 100)  cout << "   " << Dtran[i][j];
			else if (Dtran[i][j] < 1000)  cout << "  " << Dtran[i][j];
			else  cout << " " << Dtran[i][j];
		}
		cout << endl;
	}*/

	// check whether the Dtrannumber can be minizmied
	int DtranNumberAfterMinimization = MinimizeDFAStates(Dtran, AcceptStates, DtranNumber, edgeNumber);
	while (DtranNumberAfterMinimization != DtranNumber)
	{
		DtranNumber = DtranNumberAfterMinimization;
		DtranNumberAfterMinimization = MinimizeDFAStates(Dtran, AcceptStates, DtranNumber, edgeNumber);
	}

	// copy the states into the DFA table
	DFATable = new TransitionTable(DtranNumber, edgeNumber);
	for (i=0; i<DtranNumber; i++)
	{
		for (j=0; j<edgeNumber; j++)
		{
			DFATable->SetValue(i, j, Dtran[i][j]);
		}
	}

	// output the DFA table for reference
	// cout << "\n output the DFA table:\n\n states";
	/*for (j=0; j<edgeNumber; j++)
	{
		cout << "    " << edge[j];
	}
	cout<<endl;
	for (i=0; i<DtranNumber; i++)
	{
		if (i < 10)  cout << "   " << i << " ";
		else if (i < 100)  cout << "  " << i << " ";
		else if (i < 1000)  cout << " " << i << " ";
		else  cout << i << " ";
		for (j=0; j<edgeNumber; j++)
		{
			if (DFATable->GetValue(i, j) < 0)  cout << "     ";
			else if (DFATable->GetValue(i, j) < 10)  cout << "    " << DFATable->GetValue(i, j);
			else if (DFATable->GetValue(i, j) < 100)  cout << "   " << DFATable->GetValue(i, j);
			else if (DFATable->GetValue(i, j) < 1000)  cout << "  " << DFATable->GetValue(i, j);
			else  cout << " " << DFATable->GetValue(i, j);
		}
		cout << endl;
	}*/
	FinalState=DtranNumber-1;
	Move = (int**)(new int*[DtranNumber]);
	for(j=0;j<DtranNumber;j++)   
		Move[j] = new int[edgeNumber+1]; 
	for (j=0;j<DtranNumber;j++)
		for (int k=0;k<edgeNumber+1;k++)
		{   
			if (k==0)
			{
				Move[j][k] = j;
			}
			else
			    Move[j][k]=DFATable->GetValue(j,k-1);
		}
		r = DtranNumber;
		l = edgeNumber+1;

	// desconstruct Dstates and Dtran and AcceptStates arrays
	for (i=0; i<NFAStatesNumber+1; i++)
	{
		delete [] DStates[i];
		delete [] Dtran[i];
	}
	delete [] DStates;
	delete [] Dtran;
}

//check whether the strings can be accepted
void DFA::check()
{   
	// check with the filename is still the input txt
	// cout << filename <<endl;
	// first attempt to check the programming works
	/* printf("Please input the test string:\n");
	fflush(stdin);
    int i=0;
	while(WordBuffer[i-1]!='\n')
	{
		WordBuffer[i]=getchar();
		i++;
	}*/
	ifstream fin(filename.c_str());
        
	const int LINE_LENGTH = 1024;
 
	fin.getline(exp,LINE_LENGTH);
/*	int i=0;
	int row=0,line=0;
	int s=Move[row][line];
	*/
	int s;
	while ( fin.getline(WordBuffer,LINE_LENGTH) )
	{
	// identify whether we read the string we want
	//cout << WordBuffer << endl;
	int i=strlen(WordBuffer);
	
	int row=0,line=0;
	s=Move[row][line];

	for(int j=0;j<i;j++)
	{	
		line=0;	
		for (int k=0;k<edgeNumber;k++)
		{
			if(WordBuffer[j]==edge[k])
			{
				line=line+k+1;
				s=Move[row][line];
				break;
			}
		}
		for(int t=0;t<r;t++)
			if(s==Move[t][0])
			{
				row=t;
				break;
			}
			s=Move[row][0];		
	} 
/*	for (i=0; i<r; i++)
	{
		delete [] Move[i];
	}
	*/
//	delete [] Move;
	// if(s==FinalState)
	// use the acceptstates pointer to determine the function
	if (AcceptStates[s]==1)
	{
		cout<<"\n YES \n";
		//delete [] s;
	}
	else
	{
		cout<<"\n NO \n";
		//delete [] s;
	}
	}
	for (int i=0; i<r; i++)
	{
		delete [] Move[i];
	}
	delete [] Move;
}
