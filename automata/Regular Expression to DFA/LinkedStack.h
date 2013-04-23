#ifndef LINKEDSTACK_H
#define LINKEDSTACK_H

#include <iostream>
#include <stdlib.h>

using namespace std;

//--------------------------------Stack Operation--------------------------------//
//---------------------------realize the stack with template class---------------//
//-----------------------------apply to different variables----------------------//
#define NULL 0

template<class T>
class LinkedStack;
//////////////////////////////////////////////////////////
//define the LinkSNode
//////////////////////////////////////////////////////////
template <class T> 
class LinkSNode
{   
	friend class LinkedStack<T>;
	// data
	T data;
	// pointer
	LinkSNode<T>* link;
	// initial the pointer
    LinkSNode(LinkSNode<T>* ptr=NULL)
	{
		// initial the variable
		link=ptr;
	};
	// initial the data and pointer
	LinkSNode(const T& item,LinkSNode<T>* ptr=NULL)
	{
		// initial the data
		data=item;
		//initial the pointer
		link=ptr;
	};	
};
//////////////////////////////////////////LinkSNode end

//////////////////////////////////////////////////////////
// definition for LinkedStack
//////////////////////////////////////////////////////////
template<class T>
class LinkedStack //:Stack
{
public:
	// get an empty stack
    LinkedStack()
	{top=NULL;};
	//desconstruct function
	~LinkedStack()
	{makeEmpty();};
	//push x as element, push operation
	void Push(const T& x);
	//pop x as element, pop operation
	T Pop(void);
	//read the top stack element and assign to x
	T getTop(void);
	//check if the stack is empty
	bool IsEmpty(void)const
	{return (top==NULL)?true:false;};
	// get the size of the stack
	int getSize(void)const;
	// empty the stack
	void makeEmpty(void);
private:
	//top stack pointer
	LinkSNode<T>* top;
};
/////////////////////////////////////LinkedStack end

//////////////////////////////////////////////////////////
// make empty function, 
// free all the nodes occupied by the elements in the stack
//////////////////////////////////////////////////////////
template<class T>
void LinkedStack<T>::makeEmpty(void)
{
	if(top!=NULL)
	{
		// point to the node that will be deleted
		LinkSNode<T>* del;
		// delete the nodes in stack
		while(top!=NULL)
		{
			del=top;
			top=top->link;
			delete del;
		};
	}
};
///////////////////////////////////////makeEmpty() end

//////////////////////////////////////////////////////////
// push function, push x into the stack
//////////////////////////////////////////////////////////
template<class T>
void LinkedStack<T>::Push(const T& x)
{
	//set a new node with x
	//make this pointer as the toppest
	LinkSNode<T>* newNode=new LinkSNode<T>(x,top);
	if(newNode==NULL)
	{
		cerr<<"Failure to assign new node in stack!"<<endl;
		exit(1);
	}
	//get the new top
	top=newNode;
};
////////////////////////////////////////////Push() end

//////////////////////////////////////////////////////////
// pop function, pop x 
//////////////////////////////////////////////////////////
template<class T>
T LinkedStack<T>::Pop(void)
{
	if(top==NULL)
	{
		cout<<"The stack is empty, noting to pop"<<endl;
		exit(1);
	}
	//delete the pop node
	LinkSNode<T>* del=top;
	//down move the stack from top
	top=top->link;
	T x=del->data;
	delete del;

	return x;
};
/////////////////////////////////////////////Pop() end

//////////////////////////////////////////////////////////
//getTop(), get the top value in the stack to x
//////////////////////////////////////////////////////////
template<class T>
T LinkedStack<T>::getTop(void)
{
	if(top==NULL)
	{
		cout<<"The stack is empty!"<<endl;
		exit(1);
	};

	return top->data;
};
//////////////////////////////////////////getTop() end

//////////////////////////////////////////////////////////
//getSize(), get the size of the stack
//////////////////////////////////////////////////////////
template<class T>
int LinkedStack<T>::getSize()const
{
	if(top==NULL)
		return 0;
	// pointer
	LinkSNode<T>* ptr=top;
	// counter
	int count=0;
	// get the size of stack
	while(ptr!=NULL)
	{
		count++;
		ptr=ptr->link;
	};

	return count;
};
/////////////////////////////////////////getSize() end

#endif
