#include "ScopeTable.cpp"
#include <cstddef>
#include <ostream>
#include <string>
#define ROOT_ID 1

class SymbolTable {
    private:
        ScopeTable * currentScopeTable;
        int n;
    public:
        SymbolTable(int arg) {
            this->n = arg;
            this->currentScopeTable = new ScopeTable(n, NULL);
        }

        ~SymbolTable() {
            ScopeTable * temp_st;
            while(currentScopeTable != NULL) {
                temp_st = currentScopeTable;
                currentScopeTable = currentScopeTable->getParentScopeTable();
                delete temp_st;
            }
        }

        void enterScope() {
            this->currentScopeTable = new ScopeTable(n, this->currentScopeTable);
        }

        void exitScope() {
            ScopeTable * temp_st = this->currentScopeTable;
            this->currentScopeTable = temp_st->getParentScopeTable();
            delete temp_st;
        }

        bool insert(string arg_name, string arg_type, int * pos1 = NULL, int * pos2 = NULL) {
            if(this->currentScopeTable == NULL) {
                this->currentScopeTable = new ScopeTable(n, NULL);
            }
            return this->currentScopeTable->insert(arg_name, arg_type, pos1, pos2);
        }

        bool remove(string arg, int * pos1 = NULL, int * pos2 = NULL) {
            if(this->currentScopeTable == NULL) {
                return false;
            }
            return this->currentScopeTable->remove(arg, pos1, pos2);
        }

        SymbolInfo * lookup(string arg, string* tableID = NULL, int * pos1 = NULL, int * pos2 = NULL) {
            if(this->currentScopeTable == NULL) {
                return NULL;
            }
            ScopeTable * temp_sc = currentScopeTable;
            while(temp_sc != NULL) {
                SymbolInfo * temp_si = temp_sc->lookup(arg, pos1, pos2);
                if(temp_si != NULL) {
                    if(tableID != NULL) *tableID = temp_sc->getAbsoluteID();
                    return temp_si;
                }
                temp_sc = temp_sc->getParentScopeTable();
            }
            if(tableID != NULL) *tableID = "";
            return NULL;
        }

        void printCurrentScopeTable(ostream & arg = cout) {
            if(this->currentScopeTable == NULL) {
                arg<<"NO CURRENT SCOPE"<<endl;
                return;
            }
            currentScopeTable->print(arg);
        }

        void printAllScopeTable(ostream & arg = cout) {
            if(this->currentScopeTable == NULL) {
                arg<<"NO CURRENT SCOPE"<<endl;
                return;
            }
            ScopeTable * temp_st = this->currentScopeTable;
            while(temp_st != NULL) {
                temp_st->print(arg);
                temp_st = temp_st->getParentScopeTable();
            }
        }

        ScopeTable * getCurrentScopeTable() {
            return this->currentScopeTable;
        }


        string getCurrentID() {
            if(this->currentScopeTable == NULL) {
                return "";
            }
            return this->currentScopeTable->getAbsoluteID();
        }
};