#ifndef _1805097_SYMBOLTABLE_H
#define _1805097_SYMBOLTABLE_H

#include "1805097_ScopeTable.h"
#include "1805097_SymbolInfo.h"
#include <cstddef>
#include <ostream>
#include <string>
#define ROOT_ID 1


class SymbolTable {
    private:
        ScopeTable * currentScopeTable;
        int n;
        ScopeTable * prebuiltScopeTable; // will set new scope table will be set as prebuiltScopeTable (if not NULL) when enterScope() is called
    public:
        SymbolTable(int arg);

        ~SymbolTable();

        void enterScope();

        void exitScope();

        bool insert(string arg_name, string arg_type, int * pos1 = NULL, int * pos2 = NULL);

        bool insert(SymbolInfo* symbolInfo);

        bool remove(string arg, int * pos1 = NULL, int * pos2 = NULL);

        SymbolInfo * lookup(string arg, string* tableID = NULL, int * pos1 = NULL, int * pos2 = NULL);

        SymbolInfo * lookupCurrent(string arg, string* tableID = NULL, int * pos1 = NULL, int * pos2 = NULL);

        void printCurrentScopeTable(ostream & arg = cout);

        void printAllScopeTable(ostream & arg = cout);

        ScopeTable * getCurrentScopeTable();

        void replaceCurrentScopeTable(ScopeTable* arg);

        void setPrebuiltScopeTable(ScopeTable* arg);


        string getCurrentID();
};
#endif
