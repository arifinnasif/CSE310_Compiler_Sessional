#ifndef _1805097_SYMBOLINFO_H
#define _1805097_SYMBOLINFO_H

#include <string>
#include <vector>

using namespace std;

class SymbolInfo {
    private:
        string name;
        string type;

        

        bool _isArray;
        int arraySize;
        bool _isFunction;
        bool _isFunctionDefined;
        SymbolInfo * prev;
        SymbolInfo * next;
        SymbolInfo ** head;

    public:
        bool isError;

        string datatype;
        int int_val;
        double float_val;

        vector<string> arglist;
        SymbolInfo(string argName, string argType, SymbolInfo ** argHead = NULL, SymbolInfo * argPrev  = NULL, SymbolInfo * argNext  = NULL);

        ~SymbolInfo();

        void setHead(SymbolInfo** argHead);

        void setDataType(string arg);

        string getDataType();

        string getName();

        void setName(string arg);

        string getType();

        void setType(string arg);

        SymbolInfo * getNext();

        void setNext(SymbolInfo * arg);

        SymbolInfo * getPrev();

        void setPrev(SymbolInfo * arg);

        void setAsArray(int sz);

        void setAsFunction();

        void setAsFunctionDefined();

        bool isArray();
        bool isFunction();
        bool isFunctionDefined();

        int getArraySize();

};


#endif