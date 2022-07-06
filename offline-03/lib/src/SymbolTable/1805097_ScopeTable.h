#ifndef _1805097_SCOPETABLE_H
#define _1805097_SCOPETABLE_H

#include "1805097_SymbolInfo.h"

#include <cstdint>
#include <ostream>
#include <string>
#include <fstream>
#include <iostream>

#define ROOT_ID 1

using namespace std;

class ScopeTable {
    private:
        int n;
        int id;
        int childCount;
        ScopeTable * parentScopeTable;
        SymbolInfo ** buckets;

        


        uint32_t hash(string arg);

        

    public:
        ScopeTable(int arg_n);

        ScopeTable(int arg_n, ScopeTable * argParentScopeTable);

        ~ScopeTable();

        bool insert(string arg_name, string arg_type, int * pos1 = NULL, int * pos2 = NULL);

        bool insert(SymbolInfo * argSymbolInfo, int * pos1 = NULL, int * pos2 = NULL);

        SymbolInfo * lookup(string arg, int * pos1 = NULL, int * pos2 = NULL);

        bool remove(string arg, int * pos1 = NULL, int * pos2 = NULL);

        string getAbsoluteID();

        void print(ostream & arg = cout);

        ScopeTable * getParentScopeTable();

        void setParentScopeTable(ScopeTable * argParentScopeTable);

        int getBucketSize();
};


#endif