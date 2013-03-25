/* address-mapping.cc
 * Junjie Qian, jqian@cse.unl.edu
 * second problem of assignment 3 CSCE837, calculating the mapping address of the RAID block
 */
#include <fstream>
#include <iostream>
#include <stdlib.h>
#include <stdio.h>
#include <string>
#include <sstream>
#include <vector>
#include <math.h>

using namespace std;

vector<int> mappingresult(int levelnum, int length, int depth, int raidlbno);
inline int strtoint(const string& str);

int main(int argc, char **argv){
	ifstream infile;
	ofstream outfile;
	int level = 0;
	int striplength = 0;
	int stripdepth = 0;
	int raidlbn = 0;
	int found = 0;

	string line;
	string tmp;

	int diskno = 0;
	int disklbn = 0;

	infile.open(argv[1]);
	outfile.open("result");

	outfile << "Result of calculation of the different RAID sets: \n\n";

	if(!infile.is_open()){
		cerr << "NO input file!" << endl;
		return 0;
	}

	while(getline(infile,line)){
		if (line.find('*') == string::npos){
			found = line.find(":");
			int i = found;
			outfile << line.substr(0,i);

			found = line.find(",", found+1);
			int j = found;
			tmp = line.substr(i+1, j-i-1);
			level = strtoint(tmp);

			found = line.find(",", found+1);
			i = found;
			tmp = line.substr(j+1, i-j-1);
			striplength = strtoint(tmp);

			found = line.find(",", found+1);
			j = found;
			tmp = line.substr(i+1, j-i-1);
			stripdepth = strtoint(tmp);

			found = line.find(",", found+1);
			i = found;
			tmp = line.substr(j+1, i-j-1);
			raidlbn = strtoint(tmp);

			vector<int> tmpresult;
			tmpresult = mappingresult(level, striplength, stripdepth, raidlbn);
			diskno = tmpresult[0];
			disklbn = tmpresult[1];

			outfile << ": No. of the component disk: " << diskno << ", " << "No. of the logical block on that disk: " << disklbn << ". \n\n";
		}
	}
	infile.close();
	outfile.close();

	return 0;
}

vector<int> mappingresult(int levelnum, int length, int depth, int raidlbno){
	vector<int> result;
	int no;
	int lbn;
	cout << "levle: " << levelnum << endl;

	switch(levelnum){
		case(0):
			no = ceil((raidlbno%(length*depth))/depth);
			lbn = ((raidlbno/(length*depth))*depth) + (raidlbno%(length*depth));
			break;
		case(4):
			length = length -1;
			no = ceil((raidlbno%(length*depth))/depth);
			if (no>=0)
				no = no+1;
			lbn = ((raidlbno/(length*depth))*depth) + (raidlbno%(length*depth));
			break;
		case(5):
			no = (raidlbno%((length-1)*depth))/depth;
			no = (1 + no) % length;
                        lbn = (raidlbno/((length-1)*depth))*depth + raidlbno%((length-1)*depth); 
			break;
	}
	result.push_back(no);
	result.push_back(lbn);

	return result;
}

inline int strtoint(const string& str){
	istringstream i(str, istringstream::in);
	int value;

//	if (! (i >> value))
//		return 0;

	i >> value;
	return value;
} // end string to int method


