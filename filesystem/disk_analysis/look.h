/*************************************************************************
 * look.h
 * Junjie Qian, jqian@cse.unl.edu
 * c++ source code for problem 2, hard disk's scheduling algorithms
 */

#ifndef LOOK_H
#define LOOK_H

#include <cmath>
#include <vector>

using std::vector;

vector<int> look(vector<int> &queue, int cur){
          int i = queue.size();
          int j;
          vector<int> result;
          int distance = 0;

          sort(queue.begin(), queue.end());

          for (int n=0; n<i; n++){
              if(cur>queue[n] && cur<queue[n+1]){
                  j = n;
                  break;
              }
          }

          for(int n=j+1; n <i; n++){
               result.push_back(queue[n]);
               distance += abs(cur-queue[n]);
               cur = queue[n];
          }

          for(int n=j; n >=0; n--){
               result.push_back(queue[n]);
               distance += abs(cur-queue[n]);
               cur = queue[n];
          }

          result.push_back(distance);

          return result;
}

#endif
