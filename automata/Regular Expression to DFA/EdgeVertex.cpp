#include "EdgeVertex.h"



// define the edge function
Edge::Edge()
{
	number = -1;
	position = -1;
	link = NULL;
}
Edge::Edge(int num, int pos, char ch)
{
	number = num;
	position = pos;
	weight = ch;
    link = NULL;
}


// define the vertex function
Vertex::Vertex()
{
	number = -1;
	next = NULL;
	out = NULL;
}
Vertex::Vertex(int num)
{
	number = num;
	next = NULL;
	out = NULL;
}