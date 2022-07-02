#ifndef _1805097_SYMBOLINFO_H
#define _1805097_SYMBOLINFO_H

#include <string>

using namespace std;

class SymbolInfo {
    private:
        string name;
        string type;
        SymbolInfo * prev;
        SymbolInfo * next;
        SymbolInfo ** head;

    public:
        SymbolInfo(string argName, string argType, SymbolInfo ** argHead, SymbolInfo * argPrev, SymbolInfo * argNext);

        ~SymbolInfo();

        string getName();

        void setName(string arg);

        string getType();

        void setType(string arg);

        SymbolInfo * getNext();

        void setNext(SymbolInfo * arg);

        SymbolInfo * getPrev();

        void setPrev(SymbolInfo * arg);

};


#endif