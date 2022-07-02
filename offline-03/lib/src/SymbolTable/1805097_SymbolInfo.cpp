#include "1805097_SymbolInfo.h"

using namespace std;


SymbolInfo::SymbolInfo(string argName, string argType, SymbolInfo ** argHead, SymbolInfo * argPrev, SymbolInfo * argNext) {
    this->name = argName;
    this->type = argType;
    this->head = argHead;
    this->prev = argPrev;
    this->next = argNext;

    if(argPrev != NULL)
        argPrev->next = this;
    if(argNext != NULL)
        argNext->prev = this;
}

SymbolInfo::~SymbolInfo() {
    // see deletion in ll
    if(prev != NULL)
        prev->setNext(this->next);
    else
        *head = this->next;
    if(next != NULL)
        next->setPrev(this->prev);
}

string SymbolInfo::getName(){
    return name;
}

void SymbolInfo::setName(string arg){
    this->name = arg;
}

string SymbolInfo::getType(){
    return type;
}

void SymbolInfo::setType(string arg){
    this->type = arg;
}

SymbolInfo * SymbolInfo::getNext(){
    return next;
}

void SymbolInfo::setNext(SymbolInfo * arg){
    this->next = arg;
}

SymbolInfo * SymbolInfo::getPrev(){
    return prev;
}

void SymbolInfo::setPrev(SymbolInfo * arg){
    this->prev = arg;
}
