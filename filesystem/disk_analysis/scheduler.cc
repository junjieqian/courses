/*************************************************************************
 * diskscheduler.cc
 * Junjie Qian, jqian@cse.unl.edu
 * c++ source code for problem 2, hard disk's scheduling algorithms
 */

#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <stdio.h>
#include <stdlib.h>
#include <sstream>
#include <algorithm>
#include "fifo.h"
#include "look.h"
#include "sstf.h"

using namespace std;

int openfile(ifstream &infile, char* filename);
double strtoint(const string& str);

int main(int argc, char**argv){

    ifstream infile;
    ofstream outfile;
    string line;
    vector<int> queue;
    int cur = 50;  // initial cylinder location
    vector<int> fifo_result;
    vector<int> look_result;
    vector<int> sstf_result;

    int found; // used to tag the find position

    if(!openfile(infile,argv[1])){
       cerr<<"No input file!"<<endl;
       return 1;
    }

    infile.open(argv[1]);

    outfile.open("disk_scheduler");

    while(getline(infile, line)){
          outfile << line << endl;
          found = line.find(": ");
          int i = found;
          found = line.find(",", found+1);
          int j = found;
          int q = j;
          string tmp = line.substr(i+2, j-i-2);
          int n = strtoint(tmp);
          queue.push_back(n);

          int line_length = line.length();
          for (int p=q; p< line_length; p++){
              if(line[p] == ',' || line[p] == '\n'){
                   found = line.find(",", found+1);
                   i = found;
                   tmp = line.substr(j+2, i-j-2);
                   j = i;
                   n = strtoint(tmp);
                   queue.push_back(n);
              }
          }


          fifo_result = fifo(queue, cur);
          look_result = look(queue, cur);
          int q_size = queue.size();
          sstf_result = SSTF(queue, cur);

          outfile << "\nThe FIFO algorithm scheduled sequence of requests: ";
          for (int a=0; a<q_size;a++){
               outfile << fifo_result[a] << ", ";
          }
          outfile << "\n The total distance of disk head movement by FIFO is: " << fifo_result[q_size];

          outfile << "\nThe LOOK algorithm scheduled sequence of requests: ";
          for (int a=0; a< q_size;a++)
               outfile << look_result[a] << ", ";
          outfile << "\n The total distance of disk head movement by LOOK is: " << look_result[q_size];

          outfile << "\nThe SSTF algorithm scheduled sequence of requests: ";
          for (int a=0; a< q_size;a++)
               outfile << sstf_result[a] << ", ";
          outfile << "\n The total distance of disk head movement by SSTF is: " << sstf_result[q_size];

    }

    return 0;

}


// readin the filename, open the file and check whether it exists
int openfile(ifstream &infile, char* filename){
    infile.open(filename);
    if(!infile.bad()){
        infile.close();
        return 1;
    }
    else 
        return 0;
}

//convert the string to double
inline double strtoint(const string& str){
             istringstream i(str, istringstream::in);
             int value;

             if (!(i>>value))
                  return 0;
             return value;
}
