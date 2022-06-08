#include <cstdio>
#include <fstream>
#include <iostream>
#include <string>
#include <vector>
#include "1805097_SymbolTable.cpp"

using namespace std;

string INPUT_FILE = "input.txt";
string OUTPUT_FILE = "output.txt";

vector<string> split(string str, char delim) {
    int i=0;
    int start=0;

    vector<string> tkn;


    while(str[i] && str[i] != '\r') {
        if(str[i]!=delim) {
            if(i==0||str[i-1]==delim) start=i;
            if(str[i+1]=='\0' || str[i+1]=='\r' || str[i+1]==delim) {
                tkn.push_back(str.substr(start, i-start+1));
            }
        }
        i++;
    }

    return tkn;
}

int main() {
    ifstream ifile(INPUT_FILE);
    ofstream ofile(OUTPUT_FILE);
    


    string line;
    int n;
    int pos1;
    int pos2;

    vector<string> cmd;
    
    getline(ifile, line, '\n');

    n = stoi(line);

    // cout<<n<<"h";

    SymbolTable * symbolTable = new SymbolTable(n);
    

    while(getline(ifile, line, '\n')) {
        ofile<<line<<endl;
        // cout<<line<<endl;
        // while(true) {
        // getline(cin, line);
        cmd = split(line, ' ');
        
        switch (line[0]) {
            case 'I': {
                if(symbolTable->insert(cmd[1], cmd[2], &pos1, &pos2)) {
                    ofile<<"Inserted in ScopeTable# "<<symbolTable->getCurrentID()<<" at position "<<pos1<<", "<<pos2<<""<<endl;
                } else {
                    SymbolInfo * si = symbolTable->lookup(cmd[1]);
                    ofile<<"<"<<si->getName()<<","<<si->getType()<<"> already exists in current ScopeTable"<<endl;
                }
                break;
            }

            case 'L': {
                if(symbolTable->getCurrentScopeTable() == NULL) {
                    ofile<<"NO CURRENT SCOPE"<<endl;
                    break;
                }
                string t_id;
                SymbolInfo* si;
                si = symbolTable->lookup(cmd[1], &t_id, &pos1, &pos2);
                
                if(si == NULL) {
                    ofile<<"Not found"<<endl;
                } else {
                    ofile<<"Found in ScopeTable# "<<t_id<<" at position "<<pos1<<", "<<pos2<<""<<endl;
                }
                break;
            }

            case 'D': {
                if(symbolTable->getCurrentScopeTable() == NULL) {
                    ofile<<"NO CURRENT SCOPE"<<endl;
                    break;
                }
                if(symbolTable->remove(cmd[1], &pos1, &pos2)) {
                    ofile<<"Found in ScopeTable# "<<symbolTable->getCurrentID()<<" at position "<<pos1<<", "<<pos2<<""<<endl;
                    ofile<<"Deleted Entry "<<pos1<<", "<<pos2<<" from current ScopeTable"<<endl;
                } else {
                    ofile<<"Not found"<<endl;
                    ofile<<cmd[1]<<" not found"<<endl;
                }
                break;
            }

            case 'P': {
                if(cmd[1] == "A") {
                    symbolTable->printAllScopeTable(ofile);
                } else if (cmd[1] == "C") {
                    symbolTable->printCurrentScopeTable(ofile);
                }
                break;
            }

            case 'S': {
                symbolTable->enterScope();
                ofile<<"New ScopeTable with id "<<symbolTable->getCurrentID()<<" created"<<endl;
                break;
            }

            case 'E': {
                if(symbolTable->getCurrentScopeTable() == NULL) {
                    ofile<<"NO CURRENT SCOPE"<<endl;
                    break;
                }
                ofile<<"ScopeTable with id "<<symbolTable->getCurrentID()<<" removed"<<endl;
                if(symbolTable->getCurrentID() == "1") {
                    ofile<<"Destroying the First Scope"<<endl;
                }
                symbolTable->exitScope();
                ofile<<"Destroying the ScopeTable"<<endl;
                break;
            }

            default:
                ofile<<"Unknown command"<<endl;
        }
    }

    ifile.close();
    ofile.close();
    delete symbolTable;
    return 0;
}
