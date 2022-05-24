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
        SymbolInfo(string argName, string argType, SymbolInfo ** argHead, SymbolInfo * argPrev, SymbolInfo * argNext) {
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

        ~SymbolInfo() {
            // see deletion in ll
            if(prev != NULL)
                prev->setNext(this->next);
            else
                *head = this->next;

            if(next != NULL)
                next->setPrev(this->prev);
        }

        string getName(){
            return name;
        }

        void setName(string arg){
            this->name = arg;
        }

        string getType(){
            return type;
        }

        void setType(string arg){
            this->type = arg;
        }

        SymbolInfo * getNext(){
            return next;
        }

        void setNext(SymbolInfo * arg){
            this->next = arg;
        }

        SymbolInfo * getPrev(){
            return prev;
        }

        void setPrev(SymbolInfo * arg){
            this->prev = arg;
        }

};