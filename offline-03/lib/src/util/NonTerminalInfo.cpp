#include "NonTerminalInfo.h"


NonTerminalInfo::NonTerminalInfo() {
    isError = false;
    isExpressionConst = false;
}

NonTerminalInfo::NonTerminalInfo(string arg) {
    setName(arg);
    isError = false;
    isExpressionConst = false;
}

void NonTerminalInfo::setName(string arg) {
    this->name = arg;
}

string NonTerminalInfo::getName() {
    return this->name;
}