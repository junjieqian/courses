#ifndef ADJTABLE_H
#define ADJTABLE_H

#include "EdgeVertex.h"

//define the adjacenttable class
class AdjacentTable
{
private:
	Vertex *startVertex;
	int numOfVertices;
	int numOfEdges;
public:
	AdjacentTable();
	~AdjacentTable();
	int GetValueByPos(int pos) const;
	int GetPosByValue(int value) const;
	char GetWeightByPos(int v1, int v2) const;
	char GetWeightByValue(int value1, int value2) const;
	void SetValue(int value, int pos);
	void InsertVertex(int value);
	void InsertEdgeByPos(int v1, int v2, char weight);
	void InsertEdgeByValue(int value1, int value2, char weight);
	void RemoveAllEdges(void);
	void Clear(void);
	int* Closure(int *T);
	int* Move(int *T, char ch);
	void OutputNFA(void);
};
#endif