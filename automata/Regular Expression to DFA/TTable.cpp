#include "TTable.h"


// constructor, construct the function
TransitionTable::TransitionTable(int rowNum, int colNum)
{
	rowNumber = rowNum;
	colNumber = colNum;
	matrix = (int**)(new int*[rowNumber]);
	for (int i=0; i<rowNumber; i++)
	{
		matrix[i] = new int[colNumber];
	}
}

// destructor, destruct the function
TransitionTable::~TransitionTable()
{
	Clear();
}

// set the values of the elements
void TransitionTable::SetValue(int i, int j, int value)
{
	matrix[i][j] = value;
}

// get the values of the elements
int TransitionTable::GetValue(int i, int j)
{
	return matrix[i][j];
}

// state transition function
int TransitionTable::Transit(int current, char input, char *edge)
{
	for (int i=0; edge[i]!= '\0'; i++)
	{
		if (input == edge[i])
		{
			return matrix[current][i];
		}
	}
	return -1;
}

// clear the transition table
void TransitionTable::Clear(void)
{
	for (int i=0; i<rowNumber; i++)
	{
		delete [] matrix[i];
	}
	delete matrix;
}
