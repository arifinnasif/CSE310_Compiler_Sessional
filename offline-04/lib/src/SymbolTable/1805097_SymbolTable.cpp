#include "1805097_SymbolTable.h"
#include "1805097_ScopeTable.h"
#include "1805097_SymbolInfo.h"
#include <cstdlib>

using namespace std;

SymbolTable::SymbolTable(int arg) {
    this->n = arg;
    this->currentScopeTable = new ScopeTable(n, NULL);
    this->prebuiltScopeTable = NULL;
}

SymbolTable::~SymbolTable() {
    ScopeTable * temp_st;
    while(currentScopeTable != NULL) {
        temp_st = currentScopeTable;
        currentScopeTable = currentScopeTable->getParentScopeTable();
        delete temp_st;
    }

    if(prebuiltScopeTable != NULL) delete prebuiltScopeTable;
}

void SymbolTable::enterScope() {
    if(prebuiltScopeTable != NULL) {
        if(prebuiltScopeTable->getBucketSize() != this->n) {
            cerr<<"[CRITICAL ERROR] prebuiltScopeTable have different BUCKET_SIZE. EXITING...";
            exit(1);
        }

        prebuiltScopeTable->setParentScopeTable(this->currentScopeTable);
        this->currentScopeTable = prebuiltScopeTable;

        prebuiltScopeTable = NULL;
        // cout<<"using pre built"<<endl;
    } else {
        // cout<<"not using pre built"<<endl;
        this->currentScopeTable = new ScopeTable(n, this->currentScopeTable);
    }
}

void SymbolTable::exitScope() {
    ScopeTable * temp_st = this->currentScopeTable;
    this->currentScopeTable = temp_st->getParentScopeTable();
    delete temp_st;
}

bool SymbolTable::insert(string arg_name, string arg_type, int * pos1, int * pos2) {
    if(this->currentScopeTable == NULL) {
        this->currentScopeTable = new ScopeTable(n, NULL);
    }
    return this->currentScopeTable->insert(arg_name, arg_type, pos1, pos2);
}

bool SymbolTable::insert(SymbolInfo* symbolInfo) {
    if(this->currentScopeTable == NULL) {
        this->currentScopeTable = new ScopeTable(n, NULL);
    }
    return this->currentScopeTable->insert(symbolInfo);
}

bool SymbolTable::remove(string arg, int * pos1, int * pos2) {
    if(this->currentScopeTable == NULL) {
        return false;
    }
    return this->currentScopeTable->remove(arg, pos1, pos2);
}

SymbolInfo * SymbolTable::lookup(string arg, string* tableID, int * pos1, int * pos2) {
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

SymbolInfo * SymbolTable::lookupCurrent(string arg, string* tableID, int * pos1, int * pos2) {
    if(this->currentScopeTable == NULL) {
        return NULL;
    }
    return this->currentScopeTable->lookup(arg, pos1, pos2);
    if(tableID != NULL) *tableID = "";
    return NULL;
}

void SymbolTable::printCurrentScopeTable(ostream & arg) {
    if(this->currentScopeTable == NULL) {
        arg<<"NO CURRENT SCOPE"<<endl;
        return;
    }
    currentScopeTable->print(arg);
}

void SymbolTable::printAllScopeTable(ostream & arg) {
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

ScopeTable * SymbolTable::getCurrentScopeTable() {
    return this->currentScopeTable;
}

void SymbolTable::replaceCurrentScopeTable(ScopeTable* arg) {
    arg->setParentScopeTable(this->currentScopeTable->getParentScopeTable());
    this->currentScopeTable = arg;
}

void SymbolTable::setPrebuiltScopeTable(ScopeTable *arg) {
    // if(arg) cout<<"setPrebuiltScopeTable not null";
    if(arg && arg->getBucketSize() != this->n) {
        cerr<<"[WARNING] new prebuiltScopeTable have different BUCKET_SIZE"<<endl;
    }
    this->prebuiltScopeTable = arg;
}


string SymbolTable::getCurrentID() {
    if(this->currentScopeTable == NULL) {
        return "";
    }
    return this->currentScopeTable->getAbsoluteID();
}

