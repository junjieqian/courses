/*************************************************************************
 * sstf.h
 * Junjie Qian, jqian@cse.unl.edu
 * c++ source code for problem 2, hard disk's scheduling algorithms
 */

#ifndef SSTF_H
#define SSTF_H

#include <cmath>
#include <vector>

using std::vector;

vector<int> SSTF(vector<int>  &queue, int cur)
{

   int j=0;
   vector<int> result;
   int distance = 0;
   int compare = 0;
   int n = 0;

   while (!queue.empty())
   {
     n = queue.size();
     compare = abs(cur - queue[0]);

     for (int i=0; i<n; i++)
     {
       if (compare >= abs(cur - queue[i]))
       {
         compare = abs(cur - queue[i]);
         j = i;
       }
     }

     result.push_back(queue[j]);
     distance += abs(cur - queue[j]);
     cur = queue[j];
     queue.erase(queue.begin() + (j));
   }

   result.push_back(distance);

   return result;
}

#endif
