/*************************************************************************
 * fifo.h
 * Junjie Qian, jqian@cse.unl.edu
 * c++ source code for problem 2, hard disk's scheduling algorithms
 */

#ifndef FIFO_H
#define FIFO_H

#include <vector>
#include <cmath>

using std::vector;

vector<int> fifo(vector<int> &queue, int cur){
          int n = queue.size();
          vector<int> result;
          int distance = 0;

          for(int i=0;i<n;i++){
              result.push_back(queue[i]);
              distance += abs(cur - queue[i]);
              cur = queue[i];
          }

          result.push_back(distance);

          return result;
}

#endif
