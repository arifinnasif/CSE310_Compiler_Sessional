#include "1805097_SymbolInfo.cpp"
//#include <cstddef>
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

        


        uint32_t hash(string arg) {
            uint32_t hash = 0;
            // int hash = 0;
            int c;

            // cout<<"Size"<<sizeof(hash)<<endl;
            

            for(int i = 0; i < arg.length(); i++) {
                c = arg.at(i);
                hash = c + (hash << 6) + (hash << 16) - hash;
                // hash = hash % n;
            }
            
            return hash % n;
        }

        // unsigned long long hash(string arg) {
        //     unsigned long long hash = 0;
        //     unsigned long long c;
            
        //     char* str = (char*)arg.c_str();
        //     while (c = (unsigned long long) *str++) {
        //         hash = c + (hash << 6) + (hash << 16) - hash;
        //         // hash = hash % n;
        //     }
        //     cout<<n<<endl;
        //     return hash%n;
        // }

        

    public:
        ScopeTable(int arg_n, ScopeTable * argParentScopeTable) {

            
            this->n = arg_n;
            if(argParentScopeTable == NULL)
                this->id = ROOT_ID;
            else
                this->id = ++(argParentScopeTable->childCount);
            this->buckets = new SymbolInfo * [n]();
            this->parentScopeTable = argParentScopeTable;
            this->childCount = 0;

            
            // cout<<hash("foo")<<endl;
            // os<<"New ScopeTable with id "<<getAbsoluteID()<<" created"<<endl;
        }

        ~ScopeTable() {
            for(int i = 0; i < n; i++) {
                SymbolInfo* top = buckets[i];
                while(top != NULL) {
                    SymbolInfo* temp = top;
                    top = top->getNext();
                    delete temp;
                }
            }
            delete [] buckets;
            // os<<"ScopeTable with id "<<getAbsoluteID()<<" removed"<<endl;
        }

        // static void setOstream(fstream &arg) {
        //     os = arg;
        // }

        bool insert(string arg_name, string arg_type, int * pos1 = NULL, int * pos2 = NULL) {
            uint32_t h = hash(arg_name);
            int cnt = 0;
            if(buckets[h] == NULL) {
                buckets[h] = new SymbolInfo(arg_name, arg_type, &buckets[h], NULL, NULL);
                if(pos1 != NULL) *pos1 = h;
                if(pos2 != NULL) *pos2 = cnt;
                //os<<"Inserted in ScopeTable# "<<getAbsoluteID()<<" at position "<<h<<", "<<cnt<<""<<endl;
                return true;
            }
            SymbolInfo * temp = buckets[h];
            while(temp->getName().compare(arg_name) != 0) {
                cnt++;
                if(temp->getNext() == NULL) {
                    temp->setNext(new SymbolInfo(arg_name, arg_type, &buckets[h], temp, NULL));
                    if(pos1 != NULL) *pos1 = h;
                    if(pos2 != NULL) *pos2 = cnt;
                    //os<<"Inserted in ScopeTable# "<<getAbsoluteID()<<" at position "<<h<<", "<<cnt<<""<<endl;
                    return true;
                }
                temp = temp->getNext();
            }
            if(pos1 != NULL) *pos1 = -1;
            if(pos2 != NULL) *pos2 = -1;
            //os<<"<"<<arg_name<<","<<arg_type<<"> already exists in current ScopeTable"<<endl;
            return false;
        }

        SymbolInfo * lookup(string arg, int * pos1 = NULL, int * pos2 = NULL) {
            uint32_t h = hash(arg);
            SymbolInfo* temp = buckets[h];
            int cnt = 0;

            while(temp != NULL) {
                if(temp->getName().compare(arg) == 0) {
                    if(pos1 != NULL) *pos1 = h;
                    if(pos2 != NULL) *pos2 = cnt;
                    //os<<"Found in ScopeTable# "<<getAbsoluteID()<<" at position "<<h<<", "<<cnt<<""<<endl;
                    return temp;
                }
                cnt++;
                temp = temp->getNext();
            }
            if(pos1 != NULL) *pos1 = -1;
            if(pos2 != NULL) *pos2 = -1;
            //os<<"Not found"<<endl;
            return NULL;
        }

        bool remove(string arg, int * pos1 = NULL, int * pos2 = NULL) {
            SymbolInfo* temp = lookup(arg, pos1, pos2);
            if(temp != NULL) {
                delete temp;
                return true;
            }
            return false;
        }

        string getAbsoluteID() {
            string absolute_id = to_string(this->id);
            ScopeTable * temp_scopetable = this->parentScopeTable;

            while(temp_scopetable != NULL) {
                absolute_id.insert(0, to_string(temp_scopetable->id)+".");
                temp_scopetable = temp_scopetable->parentScopeTable;
            }
            return absolute_id;
        }

        void print(ostream & arg = cout) {
            string absolute_id = getAbsoluteID();

            arg<<"ScopeTable # "<<absolute_id<<endl;
            // if(&arg != &os) {
            //     os<<"ScopeTable # "<<absolute_id<<endl;
            // }
            for(int i = 0; i < n; i++) {
                arg<<i<<" --> ";
                // if(&arg != &os) {
                //     os<<i<<" --> ";
                // }
                SymbolInfo* temp = buckets[i];
                while(temp != NULL) {
                    arg<<" < "<<temp->getName()<<" : "<<temp->getType()<<">";
                    // if(&arg != &os) {
                    //     os<<" < "<<temp->getName()<<" : "<<temp->getType()<<">";
                    // }
                    temp = temp->getNext();
                }
                arg<<endl;
                // if(&arg != &os) {
                //     os<<endl;
                // }
            }
        }

        ScopeTable * getParentScopeTable() {
            return parentScopeTable;
        }
};
