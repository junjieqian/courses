/*************************************************************************
 * io_latency.cc
 * Junjie Qian, jqian@cse.unl.edu
 * c++ source code for problem 1, hard disk's I/O latency calculation
 */

#include <iostream>
#include <fstream>
#include <string>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <sstream>
#include <algorithm>

using namespace std;

int openfile(ifstream &infile, char* filename);
double iolatency(double full_seek_time, double rpm, double transfer_rate, double transfer_length, double overhead);
double strtodb(const string& str);


int main(int argc, char**argv){

    ifstream infile;
    ofstream outfile;
    string line;
    double full_seek_time;
    double rpm;
    double transfer_rate;
    double transfer_length; 
    double overhead;
    double result;
    int found; // used to tag the find position

    if(!openfile(infile,argv[1])){
       cerr<<"No input file!"<<endl;
       return 1;
    }

    infile.open(argv[1]);
    outfile.open("IO_Latency_result");

    while(getline(infile, line)){
         if (line[0] == '(')
            outfile << line;
         else{
   //         cout << line << endl;

            found = line.find("is ");  // find the first "is" position which would be the seek time
            int i = found;
            found = line.find(" ms");  // accurate the seek time int position
            int j = found;
//            cout << i << " and " << j << "and"  << line[i, j] << endl;
            string tmp = line.substr(i+3, j-i-3);
            full_seek_time = strtodb(tmp)*0.001;  // ms transfer to second
//            cout << full_seek_time << endl;

            found = line.find("= ");
            i = found;
            found = line.find(", ", found+1);
            j = found;
            tmp = line.substr(i+2, j-i-2);
            tmp.erase(remove(tmp.begin(), tmp.end(), ','), tmp.end());
            rpm = strtodb(tmp);
//            cout << rpm << " and " << tmp  << endl;

            found = line.find("= ", found+1);
            i = found;
            found = line.find("MB/s", found+1);
            j = found;
            tmp = line.substr(i+2, j-i-2);
            transfer_rate = strtodb(tmp) * 1024 * 1024;  // MB/s to B/s
//            cout << transfer_rate << " and " << tmp  << endl;

            found = line.find("is ", found+1);
            i = found;
            found = line.find("KB", found+1);
            j = found;
            tmp = line.substr(i+3, j-i-3);
            transfer_length = strtodb(tmp) * 1024;    // KB to B
//            cout << transfer_length << " and " << tmp  << endl;

            found = line.find("= ", found+1);
            i = found;
            found = line.find("ms", found+1);
            j = found;
            tmp = line.substr(i+2, j-i-2);
            overhead = strtodb(tmp) * 0.001;     // ms to second
//            cout << overhead << " and " << tmp  << endl;

//            cout << full_seek_time << ", " << rpm << ", " << transfer_rate << ", " << transfer_length << ", " << overhead << endl;
            result = iolatency(full_seek_time, rpm, transfer_rate, transfer_length, overhead);

//            cout << result << "second " << endl;

            outfile << "\n     I/O latency result is: " << result << "second.\n" << endl ;
         }
    }

    return 0;

}

// calculate the I/O latency with the parameters given
double iolatency(double full_seek_time, double rpm, double transfer_rate, double transfer_length, double overhead){
    double rotational_latency;
    double average_seek_time;
    double transfer_time;

    average_seek_time = full_seek_time/3.0;
//    rotational_latency = (1/(rpm/60))*(1/2)*1000*0.001;
    rotational_latency = 30.0/rpm;
    transfer_time = (transfer_length/transfer_rate)*1000*0.001;

    double iolatency;
    iolatency = average_seek_time + rotational_latency + transfer_time + overhead;
//    cout << average_seek_time << ", " << rotational_latency << ", " << transfer_time << ", " << overhead << endl ;

    return iolatency;
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
inline double strtodb(const string& str){
             istringstream i(str, istringstream::in);
             double value;

             if (!(i>>value))
                  return 0;
             return value;
}
