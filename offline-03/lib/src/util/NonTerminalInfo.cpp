#include "NonTerminalInfo.h"


NonTerminalInfo::NonTerminalInfo() {
    
}

NonTerminalInfo::NonTerminalInfo(string arg) {
    setName(arg);
}

void NonTerminalInfo::setName(string arg) {
    this->name = arg;
}

string NonTerminalInfo::getName() {
    return this->name;
}