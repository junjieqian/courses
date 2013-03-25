/**************************************************************
 * raid-capacity.cc
 * Junjie Qian, jqian@cse.unl.edu
 * CSCE837, third assignment, Problem1, calculate the raid's storage capacity
 **************************************************************/
#include <fstream>
#include <string>
#include <vector>
#include <iostream>
#include <math.h>
#include <sstream>
#include <algorithm>
#include <stdlib.h>
#include <stdio.h>

using namespace std;

bool checkvalid(string str, char word);
vector<int> raidresult(int levelnum, int disknum);
inline int strtoint (const string& str);

int main(int argc, char **argv){
	ifstream infile;
	ofstream outfile;
	int level = 0;
	int disk = 0;
	int capacity = 0;
	double efficiency = 0.0;
	int found = 0; // find position in the string
	string line;
	string tmp; // store sub string in line

	infile.open(argv[1]);
	outfile.open("result");

	if (!infile.is_open()){
                  cerr << "NO input file!" << endl;
                  return 1;
          }

	outfile << "Result of calculation of the different RAID sets: \n\n";

	while (getline(infile, line)){
		if(!checkvalid(line, '*')){
			found = line.find(":");
			int i = found;
			outfile << line.substr(0, i);

			found = line.find(",", found+1);
			int j = found;
			tmp = line.substr(i+1, j);
			level = strtoint(tmp);

			found = line.find(",", found+1);
			i = found;
			tmp = line.substr(j+1, i);
			disk = strtoint(tmp);

			vector<int> tmpresult;
			tmpresult = raidresult(level, disk);
			capacity = tmpresult[0];
			efficiency = tmpresult[1];

			outfile << ": Storage capacity: " << capacity << "GB, " << "Utilization efficiency: " << efficiency << "\%. \n\n";	


		} // end else
	} // end while loop
	infile.close();
	outfile.close();

	return 0;
} // end main


bool checkvalid(string str, char word){
	int n = str.size();

	for(int i=0; i<n; i++){
		if (str[i]==word){
			return true;
			break;
		}
	} // end for loop

	return false;

} // end checkvalid

vector<int> raidresult(int levelnum, int disknum){
	vector<int> result;
	int capacityresult;
	double efficiencyresult;

	switch(levelnum){
		case (0):
			capacityresult = 100 * disknum;
			efficiencyresult = 100;
			break;
		case (5):
			capacityresult = 100 * (disknum - 1);
			efficiencyresult = 100 * (disknum-1)/disknum;
			break;
		case (6):
			capacityresult = 100 * (disknum - 2);
			efficiencyresult = 100 * (disknum-2)/disknum;
			break;
		case (10):
			capacityresult = 100 * (disknum/2);
			efficiencyresult = 50;
			break;
		case (51):
			capacityresult = 100 * (disknum/2 - 1);
			efficiencyresult = 100 * ((disknum/2) - 1)/disknum;
			break;
	} // end switch
	result.push_back(capacityresult);
	result.push_back(efficiencyresult);
	return result;
} // end raid result

inline int strtoint (const string& str){
	istringstream i(str, istringstream::in);
	int value;

	if (!(i>>value))
		return 0;
	return value;

} // end string to int
