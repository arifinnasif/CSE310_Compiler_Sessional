#ifndef _NONTERMINALINFO_H
#define _NONTERMINALINFO_H

#include <string>
#include <vector>
#include "../SymbolTable/1805097_SymbolInfo.h"
#include "../SymbolTable/1805097_ScopeTable.h"

using namespace std;

class NonTerminalInfo {
    private:
    
    

    public:
    bool isError;
    bool isExpressionConst;
    string expr_val_type;
    int expr_int_val;
    double expr_float_val;

    NonTerminalInfo();
    NonTerminalInfo(string name);
    string getName();
    void setName(string arg);

    string name;
    vector<SymbolInfo*> vector_si;
    vector<string> vector_str;
    ScopeTable* scopeTable;


    ////////////////////
    string code;

    int frame_offset; // wrt BP
    bool is_global=false;
    bool is_array=false;

    string var_name;

};
#endif
