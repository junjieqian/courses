#include "Adjtable.h"

#include <iostream>
// #include <conio.h>
#include <stdlib.h>

using namespace std;

AdjacentTable::AdjacentTable()
{
	numOfVertices = 1;
	numOfEdges = 0;
	startVertex = new Vertex();
}

// destructor, destruct the function
AdjacentTable::~AdjacentTable()
{
	Vertex *p;
	Edge *q;
	p = startVertex;
	for (int i=0; i<numOfVertices; i++)
	{
		q = p->out;
		while (q)
		{
			p->out = q->link;
			delete q;
			q = p->out;
		}
		p = p->next;
	}
}

// get the value by the position
int AdjacentTable::GetValueByPos(int pos) const
{
	if ((pos >= 0) && (pos < numOfVertices))
	{
    	Vertex *p = startVertex;
    	for (int i=0; i<pos; i++)
		{
	    	p = p->next;
		}
		return p->number;
	}
	return -1;
}

// get the position by the value
int AdjacentTable::GetPosByValue(int value) const
{
	Vertex *p = startVertex;
    for (int i=0; i<numOfVertices; i++)
	{
		if (p->number == value)
		{
			return i;
		}
	    p = p->next;
	}
	return -1;
}

// get the weight by the position
char AdjacentTable::GetWeightByPos(int v1, int v2) const
{
	if ((v1 >= 0) && (v2 >= 0) && (v1 < numOfVertices) && (v2 < numOfVertices))
	{
		Vertex *p = startVertex;
		for (int i=0; i<v1; i++)
		{
	    	p = p->next;
		}
		Edge *q = p->out;
		while (q)
		{
			if (q->position == v2)
			{
				return (q->weight);
			}
			else
			{
				q = q->link;
			}
		}
	}
	return '#';
}

// get the weight by the value
char AdjacentTable::GetWeightByValue(int value1, int value2) const
{
	return GetWeightByPos(GetPosByValue(value1), GetPosByValue(value2));
}

// set the value
void AdjacentTable::SetValue(int value, int pos)
{
	/*if ((pos < 0) || (pos >= numOfVertices))
	{
		cout << "Illegal setting: The vertex doesn't exist!" << endl;
		getch();
		exit(1);
	}*/
	Vertex *p = startVertex;
	for (int i=0; i<pos; i++)
	{
		p = p->next;
	}
	p->number = value;
}

// insert the vertex
void AdjacentTable::InsertVertex(int value)
{
	int pos = GetPosByValue(value);
	/*if ((pos >= 0) && (pos < numOfVertices))
	{
		cout << "Illegal insertion: The same vertex has existed!" << endl;
		getch();
		exit(1);
	}*/
	Vertex *p = startVertex;
	while (p->next)
	{
		p = p->next;
	}
	Vertex *newVertex = new Vertex(value);
	p->next = newVertex;
	numOfVertices++;
}

// insert the edge by position
void AdjacentTable::InsertEdgeByPos(int v1, int v2, char weight)
{
	/*if ((v1 < 0) || (v1 >= numOfVertices) || (v2 < 0) || (v2 >= numOfVertices))
	{
		cout << "Illegal insertion: The vertex doesn't exist!" << endl;
		getch();
		exit(1);
	}*/
	Vertex *p = startVertex;
	for (int i=0; i<v1; i++)
	{
		p = p->next;
	}
	Edge *q = p->out;
	Edge *newEdge = new Edge(GetValueByPos(v2), v2, weight);
	if (! q)
	{
		p->out = newEdge;
		numOfEdges++;
		return;
	}
	while ((q->position != v2) && (q->link))
	{
		q = q->link;
	}
	/*if (q->position == v2)
	{
		cout << "Illegal insertion: The Edge has existed!" << endl;
		getch();
		exit(1);
	}*/
	if (! q->link)
	{
		q->link = newEdge;
		numOfEdges++;
	}
}

// insert the edge by the value
void AdjacentTable::InsertEdgeByValue(int value1, int value2, char weight)
{
	int v1 = GetPosByValue(value1), v2 = GetPosByValue(value2);
	InsertEdgeByPos(v1, v2, weight);
}

// delete all the edges
void AdjacentTable::RemoveAllEdges(void)
{
	Vertex *p = startVertex;
	for (int i=0; i<numOfVertices; i++)
	{
		Edge *q = p->out;
		while (q)
		{
			p->out = q->link;
			delete q;
			q = p->out;
		}
		p = p->next;
	}
	numOfEdges = 0;
}

// clear the adjacent table
void AdjacentTable::Clear(void)
{
	RemoveAllEdges();
	Vertex *p = startVertex->next;
	while (p)
	{
		startVertex->next = p->next;
		delete p;
		p = startVertex->next;
	}
	numOfVertices = 1;
}

// closure
int* AdjacentTable::Closure(int *T)
{
	int i = 0, j, k = 0, l, len = 0;
	int *temp = new int[128];
	Vertex *p;
	Edge *q;
	while (T[len] != -1)
	{
		len++;
	}
	while (T[i] != -1)
	{
    	for (l=0; l<k; l++)
		{
			if (T[i] == temp[l])
			{
		    	break;
			}
		}
	    if (l == k)
		{
			temp[k] = T[i];
			k++;
		}
		int pos = GetPosByValue(T[i]);
		p = startVertex;
		for (j=0; j<pos; j++)
		{
			p = p->next;
		}
		q = p->out;
		while (q)
		{
			if (q->weight == '$')
			{
				for (l=0; l<k; l++)
				{
			    	if (q->number == temp[l])
					{
			    		break;
					}
				}
		    	if (l == k)
				{
			    	temp[k] = q->number;
		    		k++;
					T[len++] = q->number;
					T[len] = -1;
				}
			}
			q = q->link;
		}
		i++;
	}
	temp[k] = -1;
	return temp;
}

// move function
int* AdjacentTable::Move(int *T, char ch)
{
	int i = 0, j, k = 0, l;
	int *temp = new int[128];
	Vertex *p;
	Edge *q;
	while (T[i] != -1)
	{
		int pos = GetPosByValue(T[i]);
		p = startVertex;
		for (j=0; j<pos; j++)
		{
			p = p->next;
		}
		q = p->out;
		while (q)
		{
			if (q->weight == ch)
			{
				for (l=0; l<k; l++)
				{
			    	if (q->number == temp[l])
					{
			    		break;
					}
				}
		    	if (l == k)
				{
			    	temp[k] = q->number;
		    		k++;
				}
			}
			q = q->link;
		}
		i++;
	}
	temp[k] = -1;
	return temp;
}

// output the adjacent table
void AdjacentTable::OutputNFA(void)
{
	Vertex *p = startVertex;
	Edge *q = new Edge();
	cout << "States   States   Symbols readed" << endl;
	for (int i=0; i<numOfVertices; i++)
	{
		cout << p->number;
		if (p->number < 10)	 cout << "      ";
		else if (p->number < 100)  cout << "     ";
		else if (p->number < 1000)	cout << "    ";
		else  cout << "   ";
		q = p->out;
		if (q)
		{
			while (q)
			{
				cout << q->number << "         " << q->weight;
				q = q->link;
			}
		}
		else 
		{
			cout << "Finalstate";
		}
		cout << endl;
		p = p->next;
	}
}

/////////////////////////////////////////////////
