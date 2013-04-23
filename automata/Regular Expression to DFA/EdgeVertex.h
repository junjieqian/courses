/////////////////////////////////////////////////
#ifndef EDJEVERTEX_H
#define EDJEVERTEX_H
#define NULL 0

// define the class of edge of adjace table
class Edge
{
public:
	int number;
	int position;
	char weight;
	Edge *link;
	Edge();
	Edge(int num, int pos, char ch);
};


/////////////////////////////////////////////////

// define the class of vertex
class Vertex
{
public:
	int number;
	Vertex *next;
	Edge *out;
	Vertex();
	Vertex(int num);
};

#endif