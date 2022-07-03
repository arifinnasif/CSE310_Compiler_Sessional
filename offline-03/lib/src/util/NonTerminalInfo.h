#ifndef _NONTERMINALINFO_H
#define _NONTERMINALINFO_H

#include <string>
#include <vector>
#include "../SymbolTable/1805097_SymbolInfo.h"

using namespace std;

class NonTerminalInfo {
    private:
    
    

    public:
    NonTerminalInfo();
    NonTerminalInfo(string name);
    string getName();
    void setName(string arg);

    string name;
    vector<SymbolInfo*> vector_si;

};
#endif
