%{
#include<bits/stdc++.h>
#include<iostream>
#include<cstdlib>
#include<cstring>
#include<cmath>
#include<vector>
#include<regex>
#include "lib/src/SymbolTable/1805097_SymbolTable.h"
#include "lib/src/util/NonTerminalInfo.h"

#define ADDITIONAL_SEM_ERR 0
// #define YYSTYPE SymbolInfo*

#define BUCKET_SIZE 32

using namespace std;

int yyparse(void);
int yylex(void);
extern FILE *yyin;
extern int line_count;
extern int error_count;
FILE *fp, *fp2, *fp3;

SymbolTable *symbolTable;

string LOG_FILENAME = "1805097_log.txt";
string TOKEN_FILENAME = "1805097_token.txt";
string CODE_FILENAME = "code.asm";
string OPTIMIZED_CODE_FILENAME = "optimized_code.asm";

ofstream log_stream;
ofstream error_stream;
ofstream token_stream(TOKEN_FILENAME);
ofstream code_stream(CODE_FILENAME);
ofstream optimized_code_stream(OPTIMIZED_CODE_FILENAME);


void yyerror(const char *s)
{
	log_stream<<"Error at line "<<line_count<<": "<<(string)s<<endl<<endl;
	error_stream<<"Error at line "<<line_count<<": "<<(string)s<<endl<<endl;

	error_count++;
}

vector<string> split(string str,   char delim) {
    int i=0;
    int start=0;

    vector<string> tkn;


    while(str[i] && str[i] != '\r') {
        if(str[i]!=delim) {
            if(i==0||str[i-1]==delim) start=i;
            if(str[i+1]=='\0' || str[i+1]=='\r' || str[i+1]==delim) {
                tkn.push_back(str.substr(start,   i-start+1));
            }
        }
        i++;
    }

    return tkn;
}

string trim(string arg) {
	string _whitespace = " \t\f\v\n\r";
	string str = arg.substr(arg.find_first_not_of(_whitespace));
	size_t found = str.find_last_not_of(_whitespace);
	if (found!=string::npos)
	    str.erase(found+1);
  	else
    	str.clear();
	return str;
}

void log(string type, string message) {
	if(type == "production") {
		// cout<<message<<endl;
		log_stream<<"Line "<<line_count<<": "<<message<<endl<<endl;
		// fprintf(fp2,"Line %d: %s\n\n",line_count, message);
	} else if (type == "matched") {
		log_stream<<message<<endl<<endl;
	} else if (type == "custom") {
		log_stream<<message<<endl<<endl;
	} else if (type == "debug") {
		log_stream<<"========================"<<endl;
		log_stream<<message<<endl;
		log_stream<<"************************"<<endl;

		cout<<"========================"<<endl;
		cout<<message<<endl;
		cout<<"************************"<<endl;
	}
}

void sem_err(string type, string message) {
	if(ADDITIONAL_SEM_ERR) {
		error_count++;
		log_stream<<"Error at line "<<line_count<<": ";
		error_stream<<"Error at line "<<line_count<<": ";
		if(type == "custom") {
			log_stream<<message<<endl<<endl;
			error_stream<<message<<endl<<endl;
		}
	}
}

void err(string type, string message) {
	error_count++;

	log_stream<<"Error at line "<<line_count<<": ";
	error_stream<<"Error at line "<<line_count<<": ";
	if(type == "multi_dec") {
		log_stream<<"Multiple declaration of "<<message<<endl<<endl;
		error_stream<<"Multiple declaration of "<<message<<endl<<endl;
	} else if(type == "var_void") {
		log_stream<<"Variable type cannot be void"<<endl<<endl;
		error_stream<<"Variable type cannot be void"<<endl<<endl;
	} else if(type == "multi_dec_param") {
		log_stream<<"Multiple declaration of "<<message<<" in parameter"<<endl<<endl;
		error_stream<<"Multiple declaration of "<<message<<" in parameter"<<endl<<endl;
	} else if(type == "redef") {
		log_stream<<"Redeclaration of "<<message<<endl<<endl;
		error_stream<<"Redeclaration of "<<message<<endl<<endl;
	} else if(type == "undec_var") {
		log_stream<<"Undeclared variable "<<message<<endl<<endl;
		error_stream<<"Undeclared variable "<<message<<endl<<endl;
	} else if(type == "undec_func") {
		log_stream<<"Undeclared function "<<message<<endl<<endl;
		error_stream<<"Undeclared function "<<message<<endl<<endl;
	} else if(type == "div_zero") {
		log_stream<<"Dividing by zero"<<endl<<endl;
		error_stream<<"Dividing by zero"<<endl<<endl;
	} else if(type == "mod_zero") {
		log_stream<<"Modulus by zero"<<endl<<endl;
		error_stream<<"Modulus by zero"<<endl<<endl;
	} else if(type == "non_int_mod") {
		log_stream<<"Non-Integer operand on modulus operator"<<endl<<endl;
		error_stream<<"Non-Integer operand on modulus operator"<<endl<<endl;
	} else if(type == "int_float") {
		// log_stream<<"float type data assigned to int type variable"<<endl<<endl;
		// error_stream<<"float type data assigned to int type variable"<<endl<<endl;

		log_stream<<"Type Mismatch"<<endl<<endl;
		error_stream<<"Type Mismatch"<<endl<<endl;

	} else if(type == "float_int") {
		// log_stream<<"int type data assigned to float type variable"<<endl<<endl;
		// error_stream<<"int type data assigned to float type variable"<<endl<<endl;

		log_stream<<"Type Mismatch"<<endl<<endl;
		error_stream<<"Type Mismatch"<<endl<<endl;

	}else if(type == "tm_func") {
		log_stream<<"Type Mismatch, "<<message<<" is a function"<<endl<<endl;
		error_stream<<"Type Mismatch, "<<message<<" is a function"<<endl<<endl;
		
	} else if(type == "tm_arr") {
		log_stream<<"Type Mismatch, "<<message<<" is an array"<<endl<<endl;
		error_stream<<"Type Mismatch, "<<message<<" is an array"<<endl<<endl;
		
	} else if(type == "not_arr") {
		log_stream<<message<<" not an array"<<endl<<endl;
		error_stream<<message<<" not an array"<<endl<<endl;
		
	} else if(type == "[non_int]") {
		log_stream<<"Expression inside third brackets not an integer"<<endl<<endl;
		error_stream<<"Expression inside third brackets not an integer"<<endl<<endl;
		
	} else if(type == "not_func") {
		log_stream<<message<<" not a function"<<endl<<endl;
		error_stream<<message<<" not a function"<<endl<<endl;
		
	} else if(type == "total_arg_mismatch") {
		log_stream<<"Total number of arguments mismatch with declaration in function "<<message<<endl<<endl;
		error_stream<<"Total number of arguments mismatch with declaration in function "<<message<<endl<<endl;
		
	} else if(type == "return_mismatch") {
		log_stream<<"Return type mismatch with function declaration in function "<<message<<endl<<endl;
		error_stream<<"Return type mismatch with function declaration in function "<<message<<endl<<endl;
		
	} else if(type == "void_func") {
		log_stream<<"Void function used in expression"<<endl<<endl;
		error_stream<<"Void function used in expression"<<endl<<endl;
		
	} else if(type == "custom") {
		log_stream<<message<<endl<<endl;
		error_stream<<message<<endl<<endl;
		
	}
}

int calc(string op, int a, int b, NonTerminalInfo* result) {
	result->expr_val_type = "int";
	if(op == "+") {
		return result->expr_int_val = a+b;
	} else if(op == "-") {
		return result->expr_int_val = a-b;
	} else if(op == "*") {
		return result->expr_int_val = a*b;
	} else if(op == "/") {
		if(b == 0) {
			err("div_zero","");
			// result_type = "NaN";
			result->isExpressionConst = false;
			return result->expr_int_val = INT_MAX;
		}
		return a/b;
	} else if(op == "%") {
		if(b == 0) {
			err("mod_zero","");
			// result_type = "NaN";
			result->isExpressionConst = false;
			return result->expr_int_val = INT_MAX;
		}
		return result->expr_int_val = a%b;
	}
}

double calc(string op, int a, double b, NonTerminalInfo* result) {
	result->expr_val_type = "float";
	if(op == "+") {
		return result->expr_float_val = a+b;
	} else if(op == "-") {
		return result->expr_float_val = a-b;
	} else if(op == "*") {
		return result->expr_float_val = a*b;
	} else if(op == "/") {
		if(b == 0) {
			err("div_zero","");
			// result_type = "NaN";
			result->isExpressionConst = false;
			return result->expr_float_val = INT_MAX;
		}
		return a/b;
	} else if(op == "%") {
		if(b == 0) err("mod_zero","");
		err("non_int_mod","");
		// result_type = "NaN";
		result->isExpressionConst = false;
		result->expr_val_type = "int";
		return result->expr_int_val = INT_MAX;
	}
}

double calc(string op, double a, double b, NonTerminalInfo* result) {
	result->expr_val_type = "float";
	if(op == "+") {
		return result->expr_float_val = a+b;
	} else if(op == "-") {
		return result->expr_float_val = a-b;
	} else if(op == "*") {
		return result->expr_float_val = a*b;
	} else if(op == "/") {
		if(b == 0) {
			err("div_zero","");
			// result_type = "NaN";
			result->isExpressionConst = false;
			return result->expr_float_val = INT_MAX;
		}
		return a/b;
	} else if(op == "%") {
		if(b == 0) err("mod_zero","");
		err("non_int_mod","");
		// result_type = "NaN";
		result->isExpressionConst = false;
		result->expr_val_type = "int";
		return result->expr_int_val = INT_MAX;
	}
}

double calc(string op, double a, int b, NonTerminalInfo* result) {
	result->expr_val_type = "float";
	if(op == "+") {
		return result->expr_float_val = a+b;
	} else if(op == "-") {
		return result->expr_float_val = a-b;
	} else if(op == "*") {
		return result->expr_float_val = a*b;
	} else if(op == "/") {
		if(b == 0) {
			err("div_zero","");
			// result_type = "NaN";
			result->isExpressionConst = false;
			return result->expr_float_val = INT_MAX;
		}
		return a/b;
	} else if(op == "%") {
		if(b == 0) err("mod_zero","");
		err("non_int_mod","");
		// result_type = "NaN";
		result->isExpressionConst = false;
		result->expr_val_type = "int";
		return result->expr_int_val = INT_MAX;
	}
}

int label_count = 0;

string get_new_label() {
	return "L_"+to_string(label_count++);
}

int frame_size = 0;
int new_frame_size_for_arg = 0;

vector< pair< string, int > > global_vars;


string get_temp_stack_slot(int offset, string str = "") {
	if(str == "") return "WORD PTR [BP-"+to_string(offset)+"]";
	else return "WORD PTR [BP-"+to_string(offset)+"+"+str+"]";
}

// void safe_delete(NonTerminalInfo * arg) {
// 	if(arg) delete arg;
// }

// void safe_delete(SymbolInfo * arg) {
// 	if(arg) delete arg;
// }

string get_mem_location(NonTerminalInfo * arg) {

	if(arg->is_global) {
		if(arg->is_array) {
			// return trim(split(arg->var_name, '[')[0]) + "[BX]";
			return arg->var_name+"[BX]";
		} else {
			return arg->var_name;
		}
	} else {
		if(arg->is_array) {
			return get_temp_stack_slot(arg->frame_offset, "SI");
		} else {
			return get_temp_stack_slot(arg->frame_offset);
		}
	}
}

string func_def_name;
string func_dec_name;

vector<string> logic_expr_stack;
vector<string> stmt_for_stack;
vector<string> stmt_if_stack;
vector<string> stmt_if_else_stack;
vector<string> stmt_while_stack;

vector<string> expr_mem_location_stack;


%}

%union {
	SymbolInfo * symbolInfo;
	NonTerminalInfo * nonTerminalInfo;
	//std::vector<SymbolInfo*> * vector_declaration_list;
}

%token IF ELSE FOR WHILE DO BREAK INT CHAR FLOAT DOUBLE VOID RETURN SWITCH CASE DEFAULT CONTINUE
%token <symbolInfo> CONST_INT CONST_FLOAT CONST_CHAR
%token ASSIGNOP LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON NOT
%token <symbolInfo> STRING
%token PRINTLN
%token <symbolInfo> ID
%token <symbolInfo> ADDOP MULOP INCOP DECOP
%token <symbolInfo> RELOP LOGICOP


%type <nonTerminalInfo> variable start program unit func_declaration func_definition
%type <nonTerminalInfo> type_specifier declaration_list parameter_list compound_statement statements
%type <nonTerminalInfo> var_declaration statement expression_statement
%type <nonTerminalInfo> expression logic_expression rel_expression simple_expression term
%type <nonTerminalInfo> unary_expression factor argument_list arguments action_after_cond
//%type <vector_declaration_list> 

%define parse.error verbose

%start start

// %left 
// %right

%nonassoc LESS_PREC_THAN_ELSE
%nonassoc ELSE

// %destructor {
// 	if($$) delete $$;
// } <nonTerminalInfo>

// %destructor {
// 	if($$) delete $$;
// } <symbolInfo>


%%

start: program {
		//write your code in this block in all the similar blocks below
		log("production", "start : program");

		

		
		// log("matched", $$->name);
	}
	;

program: program unit {
		log("production", "program : program unit");

		$$->name = $1->name + "\n" + $2->name;
		
		log("matched", $$->name);

		// safe_delete($2);

		// code
		// $$->code = $1->code;
		// $$->code += $2->code;
	}
	| unit {
		log("production", "program : unit");

		$$->name = $1->name;
		log("matched", $$->name);

		// code
		// $$->code = $1->code;
	}
	;
	
unit: var_declaration {
		log("production", "unit : var_declaration");

	
		log("matched", $$->name);

		frame_size = 0;
	}
    | func_declaration {
		log("production", "unit : func_declaration");

	
		log("matched", $$->name);

		frame_size = 0;
	}
    | func_definition {
		log("production", "unit : func_definition");

	
		log("matched", $$->name);
		frame_size = 0;

		// code
		// $$->code = $1->code;
	}
    ;
     
func_declaration: type_specifier ID LPAREN parameter_list RPAREN SEMICOLON {
		$2->setAsFunction();
		$2->datatype = $1->name;
		$2->arglist = $4->vector_str;
		if(!symbolTable->insert($2)) {
			err("multi_dec", $2->getName());
		}

		log("production", "func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON");

		$$->name = $1->name+" "+$2->getName()+" ( " + $4->name + " );";

		log("matched", $$->name);
	}
	| type_specifier ID LPAREN parameter_list error RPAREN SEMICOLON {
		$2->setAsFunction();
		$2->datatype = $1->name;
		$2->arglist = $4->vector_str;
		if(!symbolTable->insert($2)) {
			err("multi_dec", $2->getName());
		}

		log("production", "func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON");

		$$->name = $1->name+" "+$2->getName()+" ( " + $4->name + " );";

		log("matched", $$->name);
	}
	| type_specifier ID LPAREN RPAREN SEMICOLON {
		$2->setAsFunction();
		$2->datatype = $1->name;
		if(!symbolTable->insert($2)) {
			err("multi_dec", $2->getName());
		}

		log("production", "func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON");

		$$->name = $1->name+" "+$2->getName()+" ( );";

		log("matched", $$->name);
	}
	;
		 
func_definition: type_specifier ID LPAREN parameter_list RPAREN {
		symbolTable->setPrebuiltScopeTable($4->scopeTable);
		
		SymbolInfo* temp;
		if(temp = symbolTable->lookup($2->getName())) {
			if(!temp->isFunction())
				err("multi_dec", $2->getName());
			else {
				// is a function
				if(temp->isFunctionDefined())
					err("redef", $2->getName());
				else {
					// declared but undefined function
					// check param validity
					if(temp->arglist.size() == $4->vector_str.size()) {
						for(int i = 0; i < temp->arglist.size(); i++) {
							if(temp->arglist[i] != $4->vector_str[i]) {
								err("custom", to_string(i+1)+"th argument mismatch in function "+temp->getName());
							}
						}
					} else {
						err("total_arg_mismatch", temp->getName());
					}

					temp->setAsFunctionDefined();
				}

				// log("debug", temp->datatype);
				// log("debug", $1->name);

				if(temp->datatype != $1->name)
					err("return_mismatch",temp->getName());
			}

		} else {
			// not previously declared function

			$2->setAsFunction();
			$2->setAsFunctionDefined();
			$2->datatype = $1->name;
			$2->arglist = $4->vector_str;
		
			symbolTable->insert($2);
		}

		vector<string> exploded_params = split($4->name, ',');
		for(int i = 0; i < exploded_params.size(); i++) {
			if(split(exploded_params[i], ' ').size() == 1) {
				err("custom", to_string(i+1)+"th parameter's name not given in function definition of "+$2->getName());
			}
		}

		func_def_name=$2->getName();

		// code

		code_stream<<"\n\n"+$2->getName() + " PROC\n";

		if($2->getName() == "main") {
			code_stream<<"MOV AX, @DATA\n";
			code_stream<<"MOV DS, AX\n";
		}

		code_stream<<"PUSH BP\n";
		code_stream<<"MOV BP, SP\n\n";

	}
	compound_statement {
		
			

		log("production", "func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement");

		
		
		// extra semantic error
		if($1->name == "void") {
			if($7->vector_str.size()) sem_err("custom", "void function returning a non-void");
		} else {
			if(!$7->vector_str.size()) sem_err("custom", "non-void function is not returning anything");
			for(auto i : $7->vector_str) {
				if(i == "int" && $1->name == "float") continue;
				if(i != $1->name) sem_err("custom", "returned datatype does not match");
			}
		}

		$$->name = $1->name+" "+$2->getName()+" ( " + $4->name + " ) " + $7->name; // not $6 because https://www.gnu.org/software/bison/manual/bison.html#Midrule-Actions
		

		log("matched", $$->name);

		// // code


		code_stream<< "\nFUNC_"+$2->getName()+"_RETURN_LABEL:\n";

		
		code_stream<< "POP BP\n";


		if($2->getName() == "main") {
			code_stream<< "MOV AH, 4CH\n";
			code_stream<< "INT 21H\n";
			
		} else {
			code_stream<< "RET\n";
		}

		code_stream<< $2->getName()+" ENDP\n\n\n\n";
	}

	| type_specifier ID LPAREN parameter_list error RPAREN {
		symbolTable->setPrebuiltScopeTable($4->scopeTable);
		
		SymbolInfo* temp;
		if(temp = symbolTable->lookup($2->getName())) {
			if(!temp->isFunction())
				err("multi_dec", $2->getName());
			else {
				// is a function
				if(temp->isFunctionDefined())
					err("redef", $2->getName());
				else {
					// declared but undefined function
					// check param validity
					if(temp->arglist.size() == $4->vector_str.size()) {
						for(int i = 0; i < temp->arglist.size(); i++) {
							if(temp->arglist[i] != $4->vector_str[i]) {
								err("custom", to_string(i+1)+"th argument mismatch in function "+temp->getName());
							}		
						}
					} else {
						err("total_arg_mismatch", temp->getName());
					}

					temp->setAsFunctionDefined();
				}

				// log("debug", temp->datatype);
				// log("debug", $1->name);

				if(temp->datatype != $1->name)
					err("return_mismatch",temp->getName());
			}

		} else {
			// not previously declared function

			$2->setAsFunction();
			$2->setAsFunctionDefined();
			$2->datatype = $1->name;
			$2->arglist = $4->vector_str;
		
			symbolTable->insert($2);
		}

		vector<string> exploded_params = split($4->name, ',');
		for(int i = 0; i < exploded_params.size(); i++) {
			if(split(exploded_params[i], ' ').size() == 1) {
				err("custom", to_string(i+1)+"th parameter's name not given in function definition of "+$2->getName());
			}
		}

	}
	compound_statement {
		
			

		log("production", "func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement");

		// extra semantic error
		if($1->name == "void") {
			if($8->vector_str.size()) sem_err("custom", "void function returning a non-void");
		} else {
			if(!$8->vector_str.size()) sem_err("custom", "non-void function is not returning anything");
			for(auto i : $8->vector_str) {
				if(i == "int" && $1->name == "float") continue;
				if(i != $1->name) sem_err("custom", "returned datatype does not match");
			}
		}

		$$->name = $1->name+" "+$2->getName()+" ( " + $4->name + " ) " + $8->name; // not $6 because https://www.gnu.org/software/bison/manual/bison.html#Midrule-Actions

		log("matched", $$->name);

		// yyerrok;
	}

	| type_specifier ID LPAREN RPAREN {
		SymbolInfo* temp;
		if(temp = symbolTable->lookup($2->getName())) {
			if(!temp->isFunction())
				err("multi_dec", $2->getName());
			else {
				// is a function
				if(temp->isFunctionDefined())
					err("redef", $2->getName());
				else {
					// declared but undefined function
					// check param validity
					if(temp->arglist.size() != 0) {
						err("total_arg_mismatch", temp->getName());
					}

					temp->setAsFunctionDefined();
				}
				

				if(temp->datatype != $1->name)
					err("return_mismatch",temp->getName());
			}

		} else {
			// not previously declared function

			$2->setAsFunction();
			$2->setAsFunctionDefined();
			$2->datatype = $1->name;
			
		
			symbolTable->insert($2);
		}

		func_def_name=$2->getName();

		// code

		code_stream<<$2->getName() + " PROC\n";

		if($2->getName() == "main") {
			code_stream<<"MOV AX, @DATA\n";
			code_stream<<"MOV DS, AX\n";
		}

		code_stream<<"PUSH BP\n";
		code_stream<<"MOV BP, SP\n";
	}
	compound_statement {
		
		

		log("production", "func_definition : type_specifier ID LPAREN RPAREN compound_statement");

		// extra semantic error
		if($1->name == "void") {
			if($6->vector_str.size()) sem_err("custom", "void function returning a non-void");
		} else {
			if(!$6->vector_str.size()) sem_err("custom", "non-void function is not returning anything");
			for(auto i : $6->vector_str) {
				if(i == "int" && $1->name == "float") continue;
				if(i != $1->name) sem_err("custom", "returned datatype does not match");
			}
		}

		$$->name = $1->name+" "+$2->getName()+" ( ) " + $6->name;

		log("matched", $$->name);

		// // code

		

		

		code_stream<< "\nFUNC_"+$2->getName()+"_RETURN_LABEL:\n";


		code_stream<< "POP BP\n";


		if($2->getName() == "main") {
			code_stream<< "MOV AH, 4CH\n";
			code_stream<< "INT 21H\n";

		} else {
			code_stream<< "RET\n";
		}

		code_stream<< $2->getName()+" ENDP\n";
	}
	;				


parameter_list: parameter_list COMMA type_specifier ID {
		if($3->name == "void") {
			err("var_void","");
		}
		$$ = $1;
		$$->vector_str.push_back($3->name);
			
		$4->setDataType($3->name);
		if(!$$->scopeTable->insert($4)) {
			err("multi_dec_param", $4->getName());
		}
		$$->name += ", " +$3->name+" "+$4->getName();

		log("production", "parameter_list : parameter_list COMMA type_specifier ID");

		// $$->scopeTable->print(log_stream);

		log("matched", $$->name);

		// code
		frame_size+=2;
		$4->frame_offset = frame_size;
	}
	| parameter_list error COMMA type_specifier ID {
		if($4->name == "void") {
			err("var_void","");
		}
		$$ = $1;
		$$->vector_str.push_back($4->name);
			
		$5->setDataType($4->name);
		if(!$$->scopeTable->insert($5)) {
			err("multi_dec_param", $5->getName());
		}
		$$->name += ", " +$4->name+" "+$5->getName();

		log("production", "parameter_list : parameter_list COMMA type_specifier ID");

		// $$->scopeTable->print(log_stream);

		log("matched", $$->name);
	}
	| parameter_list COMMA type_specifier {
		log("production", "parameter_list : parameter_list COMMA type_specifier");

		$$ = $1;
		$$->vector_str.push_back($3->name);
		$$->name += ", " + $3->name;

		// $$->scopeTable->print(log_stream);

		log("matched", $$->name);

		// code
		frame_size+=2;
		// $4->frame_offset = frame_size;
	}
	| parameter_list error COMMA type_specifier {
		log("production", "parameter_list : parameter_list COMMA type_specifier");

		$$ = $1;
		$$->vector_str.push_back($4->name);
		$$->name += ", " + $4->name;

		// $$->scopeTable->print(log_stream);

		log("matched", $$->name);
	}
 	| type_specifier ID {
		if($1->name == "void") {
			err("var_void","");
		}
		$$ = new NonTerminalInfo();
		$$->vector_str.push_back($1->name);
		$$->scopeTable = new ScopeTable(BUCKET_SIZE);
			
		$2->setDataType($1->name);
		if(!$$->scopeTable->insert($2)) {
			err("multi_dec_param", $2->getName());
		}
		

		$$->name = $1->name+" "+$2->getName();

		log("production", "parameter_list : type_specifier ID");

		// $$->scopeTable->print(log_stream);

		log("matched", $$->name);

		// code
		frame_size+=2;
		$2->frame_offset = frame_size;
	}
	| type_specifier {
		log("production", "parameter_list : type_specifier");

		$$ = new NonTerminalInfo();
		$$->vector_str.push_back($1->name);
		$$->name = $1->name;

		// $$->scopeTable->print(log_stream);

		log("matched", $$->name);

		// code
		frame_size+=2;
		// $1->frame_offset = frame_size;
	}
 	;

 		
compound_statement: LCURL {
		symbolTable->enterScope();
	}
	
	statements RCURL {
		log("production", "compound_statement : LCURL statements RCURL");

		$$=$3;
		$$->name = "{\n" + $3->name + "\n}";

		log("matched", $$->name);

		symbolTable->printAllScopeTable(log_stream);
		log("custom", "");
		// code
		// $$->code = $3->code;

		symbolTable->exitScope();
	}
 	| LCURL {
		symbolTable->enterScope();
	}
	RCURL {
		log("production", "compound_statement : LCURL RCURL");

		$$=new NonTerminalInfo();
		$$->name = "{ }";

		log("matched", $$->name);

		symbolTable->printAllScopeTable(log_stream);
		log("custom", "");
		symbolTable->exitScope();
	}
 	;
 		    
var_declaration: type_specifier declaration_list SEMICOLON {
		///
		

		log("production", "var_declaration : type_specifier declaration_list SEMICOLON");

		if($1->name == "void") {
			err("var_void", "");
			// remove all the symbols in dec_list

			for(auto i : $2 -> vector_si) {
				if(!i->isError) { 
					SymbolInfo* temp;
					symbolTable->remove(i->getName());
				

					// log("debug", i->getName()+" "+i->datatype+" "+symbolTable->lookup(i->getName())->datatype+" <<<<<<<<<<<<<<<<<");

				}
			}
		} else {


			for(auto i : $2 -> vector_si) {
				if(!i->isError) { 
					// i->setDataType($1->name); line commented because of new instance of "c" in "int c[CONST_INT]; float c[CONST_INT];" creates a new SymbolInfo pointer, that may not be in the scopetable
					SymbolInfo* temp;
					if(temp = symbolTable->lookup(i->getName())) temp->setDataType($1->name);
				

					// log("debug", i->getName()+" "+i->datatype+" "+symbolTable->lookup(i->getName())->datatype+" <<<<<<<<<<<<<<<<<");

				}
			}
		}

		$$->name = $1-> name + " " + $2-> name + ";";

		log("matched", $$->name);
	}
	| type_specifier declaration_list error SEMICOLON {
		///
		

		log("production", "var_declaration : type_specifier declaration_list SEMICOLON");

		if($1->name == "void") {
			err("var_void", "");
			// remove all the symbols in dec_list

			for(auto i : $2 -> vector_si) {
				if(!i->isError) { 
					SymbolInfo* temp;
					symbolTable->remove(i->getName());
				

					// log("debug", i->getName()+" "+i->datatype+" "+symbolTable->lookup(i->getName())->datatype+" <<<<<<<<<<<<<<<<<");

				}
			}
		} else {


			for(auto i : $2 -> vector_si) {
				if(!i->isError) { 
					// i->setDataType($1->name); line commented because of new instance of "c" in "int c[CONST_INT]; float c[CONST_INT];" creates a new SymbolInfo pointer, that may not be in the scopetable
					SymbolInfo* temp;
					if(temp = symbolTable->lookup(i->getName())) temp->setDataType($1->name);
				

					// log("debug", i->getName()+" "+i->datatype+" "+symbolTable->lookup(i->getName())->datatype+" <<<<<<<<<<<<<<<<<");

				}
			}
		}

		$$->name = $1-> name + " " + $2-> name + ";";

		log("matched", $$->name);
	}
 	;
 		 
type_specifier: INT {
		log("production", "type_specifier : INT");
			
		$$ = new NonTerminalInfo();
		$$->setName("int");

		log("matched", $$->name);
	}
 	| FLOAT {
		log("production", "type_specifier : FLOAT");

		$$ = new NonTerminalInfo();
		$$->setName("float");

		log("matched", $$->name);
	}
 	| VOID {
		log("production", "type_specifier : VOID");

		$$ = new NonTerminalInfo();
		$$->setName("void");

		log("matched", $$->name);
	}
 	;
 		
declaration_list: declaration_list COMMA ID {	
		if($3->isError = !symbolTable->insert($3)) {
			err("multi_dec", $3->getName());
		}

		log("production", "declaration_list : declaration_list COMMA ID");
			
		$$ = $1;
		$$->name += ", " + $3->getName();
		$$->vector_si.push_back($3);

		log("matched", $$->name);

		// code

		if(symbolTable->getCurrentID() == "1") {
			// global space
			global_vars.push_back(make_pair($3->getName(), -1));
		} else {
			// local space
			// SymbolInfo* temp = symbolTable->lookupCurrent($1->getName());
			frame_size+=2;
			$3->frame_offset = frame_size;
		}
	}
	| declaration_list error COMMA ID {	
		if($4->isError = !symbolTable->insert($4)) {
			err("multi_dec", $4->getName());
		}

		log("production", "declaration_list : declaration_list COMMA ID");
			
		$$ = $1;
		$$->name += ", " + $4->getName();
		$$->vector_si.push_back($4);

		log("matched", $$->name);
	}
 	| declaration_list COMMA ID LTHIRD CONST_INT RTHIRD {
			
		if($3->isError = !symbolTable->insert($3)) {
			err("multi_dec", $3->getName());
		}

		log("production", "declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD");

		$$ = $1;
		$$->name += ", " + $3->getName() + "[" + $5->getName() + "]";
		int arr_size = stoi($5->getName());
		$3-> setAsArray(arr_size);
		$$->vector_si.push_back($3);

		if(atoi($5->getName().c_str()) < 1)
			sem_err("custom", "Invalid array size");

		log("matched", $$->name);

		// code

		if(symbolTable->getCurrentID() == "1") {
			// global space
			global_vars.push_back(make_pair($3->getName(), arr_size));

		} else {
			// local space
			// SymbolInfo* temp = symbolTable->lookupCurrent($1->getName());
			frame_size+=2*arr_size;
			$1->frame_offset = frame_size;

		}
	}
	| declaration_list COMMA ID LTHIRD CONST_FLOAT RTHIRD {
			
		if($3->isError = !symbolTable->insert($3)) {
			err("multi_dec", $3->getName());
		}

		// log("production", "declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD");

		err("[non_int]",$3->getName());

		$$ = $1;
		$$->name += ", " + $3->getName() + "[" + $5->getName() + "]";
		int arr_size = stoi($3->getName());
		$3-> setAsArray(atoi($5->getName().c_str()));
		$$->vector_si.push_back($3);

		log("matched", $$->name);

		// code

		if(symbolTable->getCurrentID() == "1") {
			// global space
			global_vars.push_back(make_pair($3->getName(), arr_size));

		} else {
			// local space
			// SymbolInfo* temp = symbolTable->lookupCurrent($1->getName());
			frame_size+=2*arr_size;
			$3->frame_offset = frame_size;

		}
	}
 	| ID {
			
		if($1->isError = !symbolTable->insert($1)) {
			err("multi_dec", $1->getName());
		}

		log("production", "declaration_list : ID");

		$$ = new NonTerminalInfo();
		$$->name = $1->getName();
		$$->vector_si.push_back($1);

		log("matched", $$->name);

		// code

		if(symbolTable->getCurrentID() == "1") {
			// global space
			global_vars.push_back(make_pair($1->getName(), -1));
		} else {
			// local space
			// SymbolInfo* temp = symbolTable->lookupCurrent($1->getName());
			frame_size+=2;
			$1->frame_offset = frame_size;
		}
	}
 	| ID LTHIRD CONST_INT RTHIRD {
			
		if($1->isError = !symbolTable->insert($1)) {
			err("multi_dec", $1->getName());
		}

		log("production", "declaration_list : ID LTHIRD CONST_INT RTHIRD");

		$$ = new NonTerminalInfo();
		$$->name = $1->getName() + "[" + $3->getName() + "]";
		int arr_size = stoi($3->getName());
		$1-> setAsArray(arr_size);
		$$->vector_si.push_back($1);

		log("matched", $$->name);

		// code

		if(symbolTable->getCurrentID() == "1") {
			// global space
			global_vars.push_back(make_pair($1->getName(), arr_size));

		} else {
			// local space
			// SymbolInfo* temp = symbolTable->lookupCurrent($1->getName());
			frame_size+=2*arr_size;
			$1->frame_offset = frame_size;

		}
	}
	| ID LTHIRD CONST_FLOAT RTHIRD {
			
		if($1->isError = !symbolTable->insert($1)) {
			err("multi_dec", $1->getName());
		}

		// log("production", "declaration_list : ID LTHIRD CONST_INT RTHIRD");
		err("[non_int]",$1->getName());

		$$ = new NonTerminalInfo();
		$$->name = $1->getName() + "[" + $3->getName() + "]";
		$1-> setAsArray(atoi($3->getName().c_str()));
		$$->vector_si.push_back($1);

		log("matched", $$->name);
	}
 	;
 		  
statements: statement {
		log("production", "statements : statement");

		log("matched", $$->name);

		// code
		// $$->code = $1->code;
	}
	| statements statement {
		log("production", "statements : statements statement");

		$$->name += "\n"+$2->name;
		for(auto i : $2->vector_str) $$->vector_str.push_back(i);

		log("matched", $$->name);

		// code
		// $$->code = $1->code;
		// $$->code += $2->code;
	}
	;
	   
statement: var_declaration {
		log("production", "statement : var_declaration");

		log("matched", $$->name);

		////
		code_stream<<"; " + regex_replace($$->name, regex("\n"), " ") + "\n\n";
	}
	| expression_statement {
		log("production", "statement : expression_statement");

		log("matched", $$->name);

		// code
		// $$->code = "\n; " + $1->name + "\n"+ $1->code;
		code_stream<<"; " + regex_replace($1->name, regex("\n"), " ") + "\n\n";
	}
	| compound_statement {
		log("production", "statement : compound_statement");

		log("matched", $$->name);
	}
	| FOR LPAREN expression_statement {
		// code
		string end_loop = get_new_label();
		string loop = get_new_label();
		string inc_label_start = get_new_label();
		string inc_label_end = get_new_label();

		code_stream<<loop+":\n";

		stmt_for_stack.push_back(inc_label_end);
		stmt_for_stack.push_back(inc_label_start);
		stmt_for_stack.push_back(loop);
		stmt_for_stack.push_back(end_loop);

		////
		code_stream<<(string)"; " + "code for FOR loop init" + "\n\n";
	} expression_statement {
		// code
		code_stream<<"CMP "+get_mem_location($5)+", 0\n";
		code_stream<<"JE "+stmt_for_stack[stmt_for_stack.size() - 1]+"\n";
		code_stream<<"JMP "+stmt_for_stack[stmt_for_stack.size() - 4]+"\n";
		code_stream<<stmt_for_stack[stmt_for_stack.size() - 3]+":\n";

		////
		code_stream<<(string)"; " + "code for cond check" + "\n\n";

	} expression {
		// code
		code_stream<<"JMP "+stmt_for_stack[stmt_for_stack.size() - 2]+"\n";
		code_stream<<stmt_for_stack[stmt_for_stack.size() - 4]+":\n";
	} RPAREN statement {
		log("production", "statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement");

		$$ = new NonTerminalInfo();
		$$->name = "for ( " + $3->name + $5->name + $7->name + " ) " + $10->name;
		for(auto i : $10->vector_str) $$->vector_str.push_back(i);

		log("matched", $$->name);

		// code
		
		
		code_stream<<"JMP "+stmt_for_stack[stmt_for_stack.size() - 3]+"\n";
		code_stream<<stmt_for_stack[stmt_for_stack.size()-1]+":\n";
		////
		code_stream<<(string)"; " + "code for FOR loop, " + regex_replace($$->name, regex("\n"), " ") + "\n\n";

		stmt_for_stack.pop_back();
		stmt_for_stack.pop_back();
		stmt_for_stack.pop_back();
		stmt_for_stack.pop_back();
	}
	| IF LPAREN expression action_after_cond RPAREN statement %prec LESS_PREC_THAN_ELSE {
		log("production", "statement : IF LPAREN expression RPAREN statement");

		$$ = new NonTerminalInfo();
		$$->name = "if ( " + $3->name + " ) \n" + $6->name;
		for(auto i : $6->vector_str) $$->vector_str.push_back(i);

		log("matched", $$->name);

		// code
		
		string end_if = stmt_if_else_stack.back();
		
		stmt_if_else_stack.pop_back();
		stmt_if_else_stack.pop_back();

		code_stream<<end_if+":\n";


		////
		code_stream<<"; " + regex_replace($$->name, regex("\n"), " ") + "\n\n";
	}
	| IF LPAREN expression action_after_cond RPAREN statement ELSE {
		{
		// code

		string else_if = stmt_if_else_stack[stmt_if_else_stack.size()-1];
		string end_if = stmt_if_else_stack[stmt_if_else_stack.size()-2];

		code_stream<<"JMP "+end_if+"\n";
		code_stream<<else_if+":\n";


		////
		code_stream<<(string)"; " + "code for IF statement else block (before)" + "\n\n";

		
		
	}
	} statement {
		log("production", "statement : IF LPAREN expression RPAREN statement ELSE statement");

		$$ = new NonTerminalInfo();
		$$->name = "if ( " + $3->name + " ) \n" + $6->name + "\nelse\n" + $9->name;
		for(auto i : $6->vector_str) $$->vector_str.push_back(i);
		for(auto i : $9->vector_str) $$->vector_str.push_back(i);

		log("matched", $$->name);

		// code

		string else_if = stmt_if_else_stack[stmt_if_else_stack.size()-1];
		string end_if = stmt_if_else_stack[stmt_if_else_stack.size()-2];
		
		code_stream<<end_if+":\n";

		////
		code_stream<<(string)"; " + "code for IF statement, " + regex_replace($$->name, regex("\n"), " ") + "\n\n";

		stmt_if_else_stack.pop_back();
		stmt_if_else_stack.pop_back();
	}
	| WHILE LPAREN {
		// code

		string loop = get_new_label();
		string end_loop = get_new_label();

		stmt_while_stack.push_back(end_loop);
		stmt_while_stack.push_back(loop);
		
		code_stream<<loop+":\n";

		////
		code_stream<<(string)"; " + "code for WHILE loop cond check (before)" + "\n\n";
		
	} expression {
		// code
		

		string loop = stmt_while_stack[stmt_while_stack.size()-1];
		string end_loop = stmt_while_stack[stmt_while_stack.size()-2];
		
		
		code_stream<<"CMP "+get_mem_location($4)+", 0\n";
		code_stream<<"JE "+end_loop+"\n";

		////
		code_stream<<(string)"; " + "code for WHILE loop cond check" + "\n\n";
		
	} RPAREN statement {
		log("production", "statement : WHILE LPAREN expression RPAREN statement");

		$$ = new NonTerminalInfo();
		$$->name = "while ( " + $4->name + " ) \n" + $7->name;
		for(auto i : $7->vector_str) $$->vector_str.push_back(i);

		log("matched", $$->name);

		// code

		string loop = stmt_while_stack[stmt_while_stack.size()-1];
		string end_loop = stmt_while_stack[stmt_while_stack.size()-2];
		
		code_stream<<"JMP "+loop+"\n";
		code_stream<<end_loop+":\n";

		////
		code_stream<<(string)"; " + "code for WHILE loop, " + regex_replace($$->name, regex("\n"), " ") + "\n\n";

		stmt_while_stack.pop_back();
		stmt_while_stack.pop_back();
	}
	| PRINTLN LPAREN ID RPAREN SEMICOLON {
		log("production", "statement : PRINTLN LPAREN ID RPAREN SEMICOLON");

		SymbolInfo* temp;
		if((temp = symbolTable->lookup($3->getName())) == NULL) {
			err("undec_var", $3->getName());

			temp = $3;

		} else if(temp->isArray()) {
			err("tm_arr", $3->getName());

		} else if(temp->isFunction()) {
			err("tm_func", $3->getName());

		}

		$$ = new NonTerminalInfo();
		$$->name = "printf ( " + $3->getName() + " ) ;";

		log("matched", $$->name);

		// code
		if(temp->table_id == "1") {
			code_stream<<"MOV CX, "+temp->getName()+"\n";
		} else {
			code_stream<<"MOV CX, "+get_temp_stack_slot(temp->frame_offset)+"\n";
		}
		
		code_stream<<"MOV OUTPUT_ARG, CX\n";
		code_stream<<"SUB SP, "+to_string(frame_size)+"\n";
		code_stream<<"CALL OUTPUT\n";
		code_stream<<"ADD SP, "+to_string(frame_size)+"\n";

		////
		code_stream<<"; " + regex_replace($$->name, regex("\n"), " ") + "\n\n";
	}
	| RETURN expression SEMICOLON {
		log("production", "statement : RETURN expression SEMICOLON");

		$$ = new NonTerminalInfo();
		$$->name = "return " + $2->name + ";";
		$$->vector_str.push_back($2->expr_val_type);

		log("matched", $$->name);

		// code
		// $$->code = $2->code;
		code_stream<<"MOV AX, "+get_mem_location($2)+"\n";
		code_stream<<"JMP FUNC_"+func_def_name+"_RETURN_LABEL\n";

		////
		code_stream<<"; " + regex_replace($$->name, regex("\n"), " ") + "\n\n";
	}
	;

action_after_cond : {
		// code

		string else_if = get_new_label();
		string end_if = get_new_label();

		
		code_stream<<"CMP "+expr_mem_location_stack.back()+", 0\n"; expr_mem_location_stack.pop_back();
		code_stream<<"JE "+else_if+"\n";
		
		stmt_if_else_stack.push_back(end_if);
		stmt_if_else_stack.push_back(else_if);
		/*
		{
		// code
		string end_if = get_new_label();

		
		code_stream<<"CMP "+get_mem_location($3)+", 0\n";
		code_stream<<"JE "+end_if+"\n";

		stmt_if_stack.push_back(end_if);
	}
		*/

	}
	  
expression_statement: SEMICOLON	{
		log("production", "expression_statement : SEMICOLON");

		$$ = new NonTerminalInfo();
		$$->name = ";";

		log("matched", $$->name);
	}		
	| expression SEMICOLON {
		log("production", "expression_statement : expression SEMICOLON");


		$$->name += ";";
		log("matched", $$->name);

		// code
		// $$->code = $1->code;
	}
	| expression error {
		log("custom", "unterminated statement found");


		$$->name += ";";
		log("matched", $$->name);
	}
	;
	  
variable: ID {
		log("production", "variable : ID");

		SymbolInfo* temp;
		$$ = new NonTerminalInfo();

		if((temp = symbolTable->lookup($1->getName())) == NULL) {
			err("undec_var", $1->getName());
			// $$->isError = true;

			temp = $1;
			temp->datatype = "undec";

		} else if(temp->isArray()) {
			err("tm_arr", $1->getName());
			// $$->isError = true;

		} else if(temp->isFunction()) {
			err("tm_func", $1->getName());
			// $$->isError = true;

		} else {
			// code
			if(temp->table_id == "1") {
				$$->is_global=true;
			} else {
				$$->frame_offset = temp->frame_offset;
			}

			$$->var_name = $1->getName();
			
		}

		
		$$->setName(temp->getName());
		
		
		// log("debug")
		$$->expr_val_type = temp->datatype;

		log("matched", $$->name);

		
	}
	| ID LTHIRD expression RTHIRD {
		log("production", "variable : ID LTHIRD expression RTHIRD");

		SymbolInfo* temp;
		$$ = new NonTerminalInfo();
		$$->code = "";

		if((temp = symbolTable->lookup($1->getName())) == NULL) {
			err("undec_var", $1->getName());
			$$->isError = true;

			temp = $1;
			temp->datatype = "undec";

		} else if(!temp->isArray()) {
			err("not_arr", $1->getName());
			$$->isError = true;

		} else {
			// code
			$$->code += $3->code;
			if(temp->table_id == "1") {
				$$->is_global=true;
				$$->is_array=true;
				$$->code += "MOV BX, "+ get_temp_stack_slot($3->frame_offset) +"\n";
				$$->code += "SHL BX, 1\n";
			} else {
				$$->is_array=true;
				$$->frame_offset = temp->frame_offset;
				$$->code += "MOV SI, "+ get_temp_stack_slot($3->frame_offset) +"\n";
				$$->code += "SHL SI, 1\n";
			}
			$$->var_name = $1->getName();
		}

		if($3->expr_val_type != "int") err("[non_int]","");

		
		$$->setName(temp->getName()+" [ "+$3->name+" ]");
		$$->expr_val_type = temp->datatype;
		

		log("matched", $$->name);
	}
	;
	 
expression: logic_expression {
		log("production", "expression : logic_expression");

		log("matched", $$->name);

		// code
		// $$->code = $1->code;
		expr_mem_location_stack.push_back(get_mem_location($$));
	}
	| variable ASSIGNOP logic_expression {
		log("production", "expression : variable ASSIGNOP logic_expression");

		if($3->expr_val_type == "void_func") {
			err("void_func", "");
			$$->expr_val_type = "void";
		}
		

		if($1->expr_val_type == "int" && $3->expr_val_type == "float") {
			err("int_float", "");
				
		} else if($1->expr_val_type == "float" && $3->expr_val_type == "int") {
			// err("float_int", "");
		}


		$$->name += " = " +$3->name;
		log("matched", $$->name);

		// code
		string temp_code = $1->code;
		

		code_stream<<"MOV CX, " + get_mem_location($3) + "\n";

		

		code_stream<<temp_code;

		code_stream<<"MOV " + get_mem_location($1) + ", CX\n";

		expr_mem_location_stack.push_back(get_mem_location($$));

		////
		code_stream<<"; " + regex_replace($$->name, regex("\n"), " ") + "\n\n";
	}
	;
			
logic_expression: rel_expression {
		log("production", "logic_expression : rel_expression");

		// log("debug", $1->name+" ==> "+$1->expr_val_type + "in logic_expression: rel_expression");

		log("matched", $$->name);

		// code
		// $$->code = $1->code;
	}
	| rel_expression LOGICOP {
		if($2->getName()=="&&") {
			string l_0 = get_new_label();
			// string l_1 = get_new_label();
			string l_done = get_new_label();

			
			code_stream<<"CMP "+get_mem_location($1)+", 0\n";
			code_stream<<"JE "+l_0+"\n";
			
			logic_expr_stack.push_back(l_done);
			logic_expr_stack.push_back(l_0);
		} else if($2->getName()=="||") {
			// string l_0 = get_new_label();
			string l_1 = get_new_label();
			string l_done = get_new_label();

			
			code_stream<<"CMP "+get_mem_location($1)+", 0\n";
			code_stream<<"JNE "+l_1+"\n";
			
			logic_expr_stack.push_back(l_done);
			logic_expr_stack.push_back(l_1);
		}
	} rel_expression {
		log("production", "logic_expression : rel_expression LOGICOP rel_expression");

		$$->expr_val_type = "int";

		if($1->isExpressionConst && $4-> isExpressionConst) {

			double val1, val2;

			if($1->expr_val_type == "float") val1 = $1->expr_float_val;
			else if($1->expr_val_type == "int") val1 = $1->expr_int_val;

			if($4->expr_val_type == "float") val2 = $4->expr_float_val;
			else if($4->expr_val_type == "int") val2 = $4->expr_int_val;

			if($2->getName() == "||") {
				$$->expr_int_val = (val1 || val2);
			} else if($2->getName() == "&&") {
				$$->expr_int_val = (val1 && val2);
			}

		} else {
			$$->isExpressionConst = false;
			if($1->expr_val_type == "void_func" || $4->expr_val_type == "void_func") {
				err("void_func", "");
				$$->expr_val_type = "void";
			} else if($1->expr_val_type == "void" || $4->expr_val_type == "void") $$->expr_val_type = "void";
		}

		// if($1->expr_val_type == "NaN" || $3->expr_val_type == "NaN") $$->expr_val_type = "NaN";


		$$->name += " " + $2->getName() + " " +$4->name;
		log("matched", $$->name);

		// code
		// string t1 = $1->code;
		// string t2 = $3->code;

		if($2->getName()=="&&") {
			string l_0 = logic_expr_stack.back(); logic_expr_stack.pop_back();
			// string l_1 = get_new_label();
			string l_done = logic_expr_stack.back(); logic_expr_stack.pop_back();

			
			code_stream<<"CMP "+get_mem_location($4)+", 0\n";
			code_stream<<"JE "+l_0+"\n";
			frame_size+=2;
			$$->frame_offset = frame_size;
			code_stream<<"MOV "+get_temp_stack_slot($$->frame_offset)+", 1\n";
			code_stream<<"JMP "+ l_done +"\n";
			code_stream<<l_0+":\n";
			code_stream<<"MOV "+get_temp_stack_slot($$->frame_offset)+", 0\n";
			code_stream<<l_done+":\n";
		} else if($2->getName()=="||") {
			// string l_0 = get_new_label();
			string l_1 = logic_expr_stack.back(); logic_expr_stack.pop_back();
			string l_done = logic_expr_stack.back(); logic_expr_stack.pop_back();

			
			code_stream<<"CMP "+get_mem_location($4)+", 0\n";
			code_stream<<"JNE "+l_1+"\n";
			frame_size+=2;
			$$->frame_offset = frame_size;
			code_stream<<"MOV "+get_temp_stack_slot($$->frame_offset)+", 0\n";
			code_stream<<"JMP "+ l_done +"\n";
			code_stream<<l_1+":\n";
			code_stream<<"MOV "+get_temp_stack_slot($$->frame_offset)+", 1\n";
			code_stream<<l_done+":\n";
		}
		
		$$->is_array = false;
		$$->is_global = false;

		////
		code_stream<<"; " + regex_replace($$->name, regex("\n"), " ") + "\n\n";
	}	
	;
			
rel_expression: simple_expression {
		log("production", "rel_expression : simple_expression");

		// log("debug", $1->name+" ==> "+$1->expr_val_type + "in rel_expression: simple_expression");

		log("matched", $$->name);

		// code
		// $$->code = $1->code;
	}
	| simple_expression RELOP simple_expression	{
		log("production", "rel_expression : simple_expression RELOP simple_expression");

		$$->expr_val_type = "int";

		

		if($1->isExpressionConst && $3->isExpressionConst) {
			double val1, val2;

			if($1->expr_val_type == "float") val1 = $1->expr_float_val;
			else if($1->expr_val_type == "int") val1 = $1->expr_int_val;

			if($3->expr_val_type == "float") val2 = $3->expr_float_val;
			else if($3->expr_val_type == "int") val2 = $3->expr_int_val;

			if($2->getName() == "==") {
				$$->expr_int_val = (val1 == val2);
			} else if($2->getName() == "<=") {
				$$->expr_int_val = (val1 <= val2);
			} else if($2->getName() == ">=") {
				$$->expr_int_val = (val1 >= val2);
			} else if($2->getName() == "<") {
				$$->expr_int_val = (val1 < val2);
			} else if($2->getName() == ">") {
				$$->expr_int_val = (val1 > val2);
			}
		} else {
			$$->isExpressionConst = false;
			if($1->expr_val_type == "void_func" || $3->expr_val_type == "void_func") {
				err("void_func", "");
				$$->expr_val_type = "void";
			} else if($1->expr_val_type == "void" || $3->expr_val_type == "void") $$->expr_val_type = "void";
		}

		
		// if($1->expr_val_type == "NaN" || $3->expr_val_type == "NaN") $$->expr_val_type = "NaN";

		$$->name += " " + $2->getName() + " " +$3->name;
		log("matched", $$->name);

		// code
		
		code_stream<<"MOV AX, "+get_mem_location($1)+"\n";
		code_stream<<"CMP AX, " + get_mem_location($3) + "\n";

		string l_done = get_new_label();
		string l1 = get_new_label();

		if($2->getName() == "==") {
			code_stream<<"JE "+l1+"\n";
		} else if($2->getName() == "<=") {
			code_stream<<"JLE "+l1+"\n";
		} else if($2->getName() == ">=") {
			code_stream<<"JGE "+l1+"\n";
		} else if($2->getName() == "<") {
			code_stream<<"JL "+l1+"\n";
		} else if($2->getName() == ">") {
			code_stream<<"JG "+l1+"\n";
		}
		
		frame_size+=2;
		$$->frame_offset = frame_size;
		code_stream<<"MOV "+get_temp_stack_slot($$->frame_offset)+", 0\n";
		code_stream<<"JMP " + l_done + "\n";
		code_stream<<l1+":\n";
		code_stream<<"MOV "+get_temp_stack_slot($$->frame_offset)+", 1\n";
		code_stream<<l_done+":\n";
		$$->is_array = false;
		$$->is_global = false;

		////
		code_stream<<"; " + regex_replace($$->name, regex("\n"), " ") + "\n\n";
	}
	;
				
simple_expression: term {
		log("production", "simple_expression : term");

		// log("debug", $1->name+" ==> "+$1->expr_val_type + "simple_expression: term");

		log("matched", $$->name);

		// code
		// $$->code = $1->code;
	}
	| simple_expression ADDOP term {
		log("production", "simple_expression : simple_expression ADDOP term");

		if($1->isExpressionConst && $3->isExpressionConst) {
			if($1->expr_val_type == "int" && $3->expr_val_type == "int") {
				calc($2->getName(), $1->expr_int_val, $3->expr_int_val, $$);
			} else if($1->expr_val_type == "int" && $3->expr_val_type == "float") {
				calc($2->getName(), $1->expr_int_val, $3->expr_float_val, $$);
			} else if($1->expr_val_type == "float" && $3->expr_val_type == "float") {
				calc($2->getName(), $1->expr_float_val, $3->expr_float_val, $$);
			} else if($1->expr_val_type == "float" && $3->expr_val_type == "int") {
				calc($2->getName(), $1->expr_float_val, $3->expr_int_val, $$);
			}
		} else {
			$$->isExpressionConst = false;
			if($1->expr_val_type == "void_func" || $3->expr_val_type == "void_func") {
				err("void_func", "");
				$$->expr_val_type = "void";
			}
			else if($1->expr_val_type == "void" || $3->expr_val_type == "void") $$->expr_val_type = "void";
			else if($1->expr_val_type == "float" || $3->expr_val_type == "float") $$->expr_val_type = "float";
			else $$->expr_val_type = "int";
		}

		$$->name += " " + $2->getName() + " " +$3->name;
		log("matched", $$->name);

		// code
		
		code_stream<<"MOV CX, "+get_mem_location($1)+"\n";
		if($2->getName() == "+") {
			code_stream<<"ADD CX, "+get_mem_location($3)+"\n";
		} else {
			code_stream<<"SUB CX, "+get_mem_location($3)+"\n";
		}
		frame_size+=2;
		$$->frame_offset = frame_size;
		
		code_stream<<"MOV "+get_temp_stack_slot($$->frame_offset)+", CX\n";
		$$->is_array = false;
		$$->is_global = false;

		////
		code_stream<<"; " + regex_replace($$->name, regex("\n"), " ") + "\n\n";
	}

	| simple_expression ADDOP error term{
		log("production", "simple_expression : simple_expression ADDOP error term");

		if($1->expr_val_type == "void_func" || $4->expr_val_type == "void_func") {
			err("void_func", "");
			$$->expr_val_type = "void";
		}
		$$->isExpressionConst = false;

		yyerrok;

		

		$$->name += " " + $2->getName() + " " +$4->name;
		log("matched", $$->name);

		
	}
	;
					
term: unary_expression {
		log("production", "term : unary_expression");

		// log("debug", $1->name+" ==> "+$1->expr_val_type + "in term : unary_expression");

		log("matched", $$->name);

		// code
		// $$->code = $1->code;
	}
    | term MULOP unary_expression {
		log("production", "term : term MULOP unary_expression");

		

		if($1->isExpressionConst && $3->isExpressionConst) {
			if($1->expr_val_type == "int" && $3->expr_val_type == "int") {
				calc($2->getName(), $1->expr_int_val, $3->expr_int_val, $$);
			} else if($1->expr_val_type == "int" && $3->expr_val_type == "float") {
				calc($2->getName(), $1->expr_int_val, $3->expr_float_val, $$);
			} else if($1->expr_val_type == "float" && $3->expr_val_type == "float") {
				calc($2->getName(), $1->expr_float_val, $3->expr_float_val, $$);
			} else if($1->expr_val_type == "float" && $3->expr_val_type == "int") {
				calc($2->getName(), $1->expr_float_val, $3->expr_int_val, $$);
			}
		} else {
			$$->isExpressionConst = false;
			

			if($1->expr_val_type == "void_func" || $3->expr_val_type == "void_func") {
				err("void_func", "");
				$$->expr_val_type = "void";
			}
			else if($1->expr_val_type == "void" || $3->expr_val_type == "void") $$->expr_val_type = "void";
			else if($1->expr_val_type == "float" || $3->expr_val_type == "float") $$->expr_val_type = "float";
			else $$->expr_val_type = "int";

			if($2->getName() == "/" && $3->isExpressionConst) {
				//handles <non_const> / 0
				if($3->isExpressionConst)
					if(($3->expr_val_type == "int" && $3->expr_int_val == 0) || ($3->expr_val_type == "float" && $3->expr_float_val == 0))
						err("div_zero","");

			} else if($2->getName() == "%") {
				//handles <non_const> % 0
				if($3->isExpressionConst)
					if(($3->expr_val_type == "int" && $3->expr_int_val == 0) || ($3->expr_val_type == "float" && $3->expr_float_val == 0))
						err("mod_zero","");

				//handles <non_int> % <non_int>
				if($1->expr_val_type == "float" ||  $3->expr_val_type == "float") {
					err("non_int_mod","");
				}

				$$->expr_val_type = "int";
			}

		}
		

		$$->name += " " + $2->getName() + " " +$3->name;
		log("matched", $$->name);

		// code
		
		code_stream<<"MOV AX, "+get_mem_location($1)+"\n";
		code_stream<<"MOV DX, 0\n";
		code_stream<<"CWD\n";
		if($2->getName() == "*") {
			code_stream<<"IMUL "+get_mem_location($3)+"\n";
		} else {
			code_stream<<"IDIV "+get_mem_location($3)+"\n";
		}
		frame_size+=2;
		$$->frame_offset = frame_size;
		if($2->getName() == "%") {
			code_stream<<"MOV "+get_temp_stack_slot($$->frame_offset)+", DX\n";
		} else {
			code_stream<<"MOV "+get_temp_stack_slot($$->frame_offset)+", AX\n";
		}
		$$->is_array = false;
		$$->is_global = false;

		////
		code_stream<<"; " + regex_replace($$->name, regex("\n"), " ") + "\n\n";
	}
    ;

unary_expression: ADDOP unary_expression {
		log("production", "unary_expression : ADDOP unary_expression");

		$$ = $2;
		$$-> name = $1->getName()+" "+$2->name;

		if($2->expr_val_type == "void_func") {
			err("void_func", "");
			$$->expr_val_type = "void";
		}

		if($2->isExpressionConst && $1->getName() == "-") {
			if($2->expr_val_type == "int") {
				$$-> expr_int_val = - ($2->expr_int_val);

			} else if($2->expr_val_type == "float") {
				$$-> expr_float_val = - ($2->expr_float_val);

			}
		}

		log("matched", $$->name);

		// code
		// $$->code = $2->code;
		if($1->getName() == "-") {
			code_stream<<"MOV CX, " + get_mem_location($2) +"\n";
			code_stream<<"NEG CX\n";
			frame_size+=2;
			code_stream<<"MOV "+get_temp_stack_slot(frame_size)+", CX\n";
			$$->frame_offset = frame_size;
			$$->is_array = false;
			$$->is_global = false;

			////
			code_stream<<"; " + regex_replace($$->name, regex("\n"), " ") + "\n\n";
		}
		

		
	}
	| NOT unary_expression {
		log("production", "unary_expression : NOT unary_expression");

		$$ = $2;
		$$-> name = "! "+$2->name;

		if($2->expr_val_type == "void_func") {
			err("void_func", "");
			$$->expr_val_type = "void";
		}

		if($2->expr_val_type == "int") {
			$$-> expr_val_type = "int";
			if($2->isExpressionConst) $$-> expr_int_val = ! ($2->expr_int_val);

		} else if($2->expr_val_type == "float") {
			$$-> expr_val_type = "int";
			if($2->isExpressionConst) $$-> expr_int_val = ! ($2->expr_float_val);

		} else if($2->expr_val_type == "void") {
			$$-> expr_val_type = "void";
			
		}

		log("matched", $$->name);

		// code
		// $$->code = $2->code;
		code_stream<<"CMP "+get_mem_location($2)+", 0\n";
		string l1 = get_new_label();
		string l2 = get_new_label();
		frame_size+=2;
		code_stream<<"JE " + l1 + "\n";
		code_stream<<"MOV "+get_temp_stack_slot(frame_size)+", 0\n";
		code_stream<<"JMP "+l2+"\n";
		code_stream<<l1+":\n";
		code_stream<<"MOV "+get_temp_stack_slot(frame_size)+", 1\n";
		code_stream<<l2+":\n";
		$$->frame_offset = frame_size;
		$$->is_array = false;
		$$->is_global = false;

		////
		code_stream<<"; " + regex_replace($$->name, regex("\n"), " ") + "\n\n";
		

	}
	| factor {
		log("production", "unary_expression : factor");

		// log("debug", $1->name+" ==> "+$1->expr_val_type + "in unary expression: factor");

		log("matched", $$->name);

		// code
		// $$->code = $1->code;
	}
	;
	
factor: variable {
		log("production", "factor : variable");

		log("matched", $$->name);

		// code
		// $$->code = $1->code;
		code_stream<<$1->code;
	}
	| ID LPAREN argument_list RPAREN {
		log("production", "factor : ID LPAREN argument_list RPAREN");

		$$ = new NonTerminalInfo();

		SymbolInfo* temp;
		if((temp = symbolTable->lookup($1->getName())) == NULL) {
			err("undec_func", $1->getName());
		} else if (!temp->isFunction()) {
			err("not_func", $1->getName());
		} else {
			// is a declared function
			$$->expr_val_type = temp->datatype;
			// log("debug", temp->datatype);
			if(temp->datatype == "void") {
				$$->expr_val_type+="_func"; // to detect "void func in expr error"
			}
			// log("debug", $$->expr_val_type);

			if(temp->arglist.size() == $3->vector_str.size()) {
				for(int i = 0; i < temp->arglist.size(); i++) {
					if(temp->arglist[i] != $3->vector_str[i]) {
						// log("debug", temp->arglist[i] + $3->vector_str[i]);
						// *** the following check is done to for the sake of resemblance with sample io ***
						SymbolInfo* temp2 = symbolTable->lookup(trim(split($3->name, ' ')[i]));
						if(!(temp2 && temp2->isArray())) err("custom", to_string(i+1)+"th argument mismatch in function "+temp->getName());


						// *** the following line is added to for the sake of resemblance with sample io ***
						break;

					}
				}
			} else {
				err("total_arg_mismatch", temp->getName());
			}
		}

		
		$$->setName($1->getName() + " ( " + $3->name + " )");

		log("matched", $$->name);
		// safe_delete($3);

		// code
		if(!error_count) {
			// $$->code = $3->code;
			for(int i = 0; i < $3->vector_NTmem_location.size(); i++) {
				code_stream<<"MOV CX, "+$3->vector_NTmem_location[i]+"\n";
				
				code_stream<<"MOV "+get_temp_stack_slot(frame_size
														
														+2/*for new func ret addr*/
														+2/*for old func BP*/
														+2*(i+1)/*actual offset wrt new BP*/)+", CX\n";
				
			}
			code_stream<<"SUB SP, "+to_string(frame_size)+"\n";
			code_stream<<"CALL "+$1->getName()+"\n";
			code_stream<<"ADD SP, "+to_string(frame_size)+"\n";
			frame_size+=2;
			$$->frame_offset = frame_size;
			code_stream<<"MOV "+get_temp_stack_slot($$->frame_offset)+", AX\n";
		}
	}
	| LPAREN expression RPAREN {
		log("production", "factor : LPAREN expression RPAREN");

		$$ = $2;
		$$->name = "( " + $2->name + " )";
		log("matched", $$->name);

		// code
		// $$->code = $2->code;
	}
	| CONST_INT {
		log("production", "factor : CONST_INT");

		$$ = new NonTerminalInfo();
		$$->name = $1->getName();
		$$->expr_val_type = "int";
		$$->expr_int_val = atoi($1->getName().c_str());
		$$->isExpressionConst = true;
		log("matched", $$->name);

		// code
		frame_size+=2;
		$$->frame_offset = frame_size;
		
		code_stream<<"MOV " + get_temp_stack_slot($$->frame_offset) +", "+$1->getName()+"\n";
	}
	| CONST_FLOAT  {
		log("production", "factor : CONST_FLOAT");

		$$ = new NonTerminalInfo();
		$$->name = $1->getName();
		$$->expr_val_type = "float";
		$$->expr_float_val = atof($1->getName().c_str());
		$$->isExpressionConst = true;
		log("matched", $$->name);
	}
	| variable INCOP {
		log("production", "factor : variable INCOP");

		$$->name += " ++";
		
		log("matched", $$->name);

		// code
		string temp_code = $1->code;
		code_stream<< $1->code;
		
		code_stream<< "MOV CX, " + get_mem_location($1) +"\n";

		frame_size+=2;

		code_stream<<"MOV "+ get_temp_stack_slot(frame_size) +", CX\n"; // frame_size is the frame offset of $$. not assigned before this line for the $1->frame_offset might change also
		
		
		code_stream<< "INC " + get_mem_location($1) +"\n";

		$$->frame_offset=frame_size;
		$$->is_array=false;
		$$->is_global=false;

	}
	| variable DECOP {
		log("production", "factor : variable DECOP");

		$$->name += " --";
		
		log("matched", $$->name);
		

		// code
		string temp_code = $1->code;
		code_stream<< $1->code;
		
		code_stream<< "MOV CX, " + get_mem_location($1) +"\n";

		frame_size+=2;

		code_stream<<"MOV "+ get_temp_stack_slot(frame_size) +", CX\n"; // frame_size is the frame offset of $$. not assigned before this line for the $1->frame_offset might change also
		
		
		code_stream<< "DEC " + get_mem_location($1) +"\n";

		$$->frame_offset=frame_size;
		$$->is_array=false;
		$$->is_global=false;
	}
	;
	
argument_list: arguments {
		log("production", "argument_list : arguments");

		$$ = $1;

		log("matched", $$->name);

		// code
		// $$->code = $1->code;

	}
	| {
		log("production", "argument_list : ");

		$$ = new NonTerminalInfo();
		$$->name = " ";

		log("matched", $$->name);
	}
	;
	
arguments: arguments COMMA logic_expression {
		log("production", "arguments : arguments COMMA logic_expression");

		// log("debug", $3->name+" ==> "+$3->expr_val_type + "in arguments: arguments COMMA logic_expression");
		$$ = $1;

		$$->vector_str.push_back($3->expr_val_type);
		$$->name += ", " + $3->name;

		log("matched", $$->name);
		// safe_delete($3);

		// code
		// $$->code += $3->code;
		// new_frame_size_for_arg += 2;
		// $$->vector_int.push_back(new_frame_size_for_arg);
		$$->vector_NTinfo.push_back($3);
		$$->vector_NTmem_location.push_back(get_mem_location($3));
	}
	| logic_expression {
		log("production", "arguments : logic_expression");

		$$ = new NonTerminalInfo();
		$$->name = $1->name;
		$$->vector_str.push_back($1->expr_val_type);

		log("matched", $$->name);

		// safe_delete($1);

		// code
		// $$->code = $1->code;
		// new_frame_size_for_arg += 2;
		// $$->vector_int.push_back(new_frame_size_for_arg);
		$$->vector_NTinfo.push_back($1);
		$$->vector_NTmem_location.push_back(get_mem_location($1));
	}
	;
 

%%
int main(int argc,char *argv[])
{

	if((fp=fopen(argv[1],"r"))==NULL)
	{
		printf("Cannot Open Input File.\n");
		exit(1);
	}

	// fp2= fopen(argv[2],"w");
	// fclose(fp2);
	// fp3= fopen(argv[3],"w");
	// fclose(fp3);
	
	// fp2= fopen(argv[2],"a");
	// fp3= fopen(argv[3],"a");
	if(argc >= 4) {
		log_stream.open(argv[2]);
		error_stream.open(argv[3]);
	} else {
		log_stream.open("log.txt");
		error_stream.open("error.txt");
	}
	


	symbolTable = new SymbolTable(BUCKET_SIZE);
	

	yyin=fp;


	
	code_stream<<".MODEL SMALL"<<endl; 
	code_stream<<".STACK 100H "<<endl;
	code_stream<<".CODE"<<endl;
	// code goes here
	code_stream<<"OUTPUT PROC\n\
	    LEA SI, OUTPUT_PROC_OUTSTRING\n\
	    ADD SI, 6\n\
	    MOV AX, OUTPUT_ARG\n\
	    \n\
	    CMP AX, 0     \n\
	    JL IS_NEG\n\
	    MOV OUTPUT_PROC_IS_NEG, 0\n\
	    \n\
	    JMP END_IS_NEG\n\
	    IS_NEG:  \n\
	    MOV OUTPUT_PROC_IS_NEG, 1\n\
	    NEG AX\n\
	    \n\
	    END_IS_NEG:\n\
	    \n\
	    PRINT_LOOP:\n\
	        DEC SI\n\
	        \n\
	        MOV DX, 0\n\
	        ; DX:AX = 0000:AX\n\
	        \n\
	        MOV CX, 10\n\
	        DIV CX\n\
	        \n\
	        ADD DL, '0'\n\
	        MOV [SI], DL\n\
	        \n\
	        CMP AX, 0\n\
	        JNE PRINT_LOOP\n\
	    \n\
	    \n\
	    CMP OUTPUT_PROC_IS_NEG, 0\n\
	    JE END_ADD_MINUS\n\
	    \n\
	    ;ADD MINUS\n\
	    DEC SI\n\
	    MOV [SI], '-'\n\
	    \n\
	    END_ADD_MINUS:\n\
	    MOV DX, SI\n\
	    MOV AH, 9\n\
	    INT 21H \n\
	    \n\
	    LEA DX, NL\n\
	    MOV AH, 09H\n\
	    INT 21H\n\
	    \n\
	    RET\n\
	\n\
	OUTPUT ENDP\n"<<endl;

			

			

		
	yyparse();

	if(error_count) {
		// delete contents of code.asm
		code_stream.close();
		code_stream.open(CODE_FILENAME, ofstream::out | ofstream::trunc);
		code_stream.close();

		optimized_code_stream.close();
	} else {
		code_stream<<".DATA"<<endl;
			code_stream<<"OUTPUT_ARG             DW ?\n\
			OUTPUT_PROC_OUTSTRING	DB \"000000$\" \n\
			OUTPUT_PROC_IS_NEG		DB 0  \n\
			\n\
			CR						EQU 0DH\n\
			LF						EQU 0AH\n\
			\n\
			NL						DB CR,LF,'$'\n"<<endl;

			code_stream<<"; global var section" <<endl;

			// global data goes here
			for(auto g : global_vars) {
				if(g.second == -1) {
					// is not an array
					code_stream<<g.first<<" DW 0"<<endl;
				} else {
					// is an array
					code_stream<<g.first<<" DW "<<g.second<<" DUP(0)"<<endl;
				}
			}

		code_stream<<"END MAIN"<<endl;
		code_stream.close();

		// optimization
		ifstream input_from_code(CODE_FILENAME);
		string line;

		string prev_dst="";
		string prev_src="";

		bool is_in_a_func = false;

		while(getline(input_from_code, line)) {
			string replacement_for_current_line = line;

			if(line.size() <= 2 ) {optimized_code_stream<<replacement_for_current_line<<endl; continue;}
			if(line.size() >= 1 && line.substr(0,1) == ";")  {optimized_code_stream<<replacement_for_current_line<<endl; continue;}

			if(line.size() > 4 && line.substr(line.size()-4) == "PROC") is_in_a_func = true;
			else if(line.size() > 4 && line.substr(line.size()-4) == "ENDP") is_in_a_func = false;

			// handle mov only
			string dst = "";
			string src = "";
			
			if(is_in_a_func) {
				if(line.substr(0,3) == "MOV") {
					auto temp = split(line.substr(4), ',');
					dst = trim(temp[0]);
					src = trim(temp[1]);

					if(prev_dst == src && prev_src == dst || prev_dst == dst && prev_src == src) {
						src = prev_src;
						dst = prev_dst;

						replacement_for_current_line = "; removed for peephole";
					}
				
				}
			}

			prev_dst=dst;
			prev_src=src;

			optimized_code_stream<<replacement_for_current_line<<endl;
		}

		input_from_code.close();
		optimized_code_stream.close();
		
	}

	symbolTable->printAllScopeTable(log_stream);

	log_stream<<endl<<"Total lines: "<<line_count<<endl;
    log_stream<<"Total errors: "<<error_count<<endl;
	

	// fclose(fp2);
	// fclose(fp3);

	log_stream.close();
	error_stream.close();

	

	
	return 0;
}

/*
makefile
========

CC			= g++
CXXFLAGS	= -g -w -std=c++17
YC			= yacc
YCFLAGS		= -d -Wcounterexamples
LC			= flex
LCFLAGS		=

LIBDIR = lib
STDIR = lib/src/SymbolTable
UTILDIR= lib/src/util


a.out: y.tab.o lex.yy.o $(LIBDIR)/1805097_SymbolTable.o $(LIBDIR)/1805097_ScopeTable.o $(LIBDIR)/1805097_SymbolInfo.o $(LIBDIR)/NonTerminalInfo.o
	$(CC) $(CXXFLAGS) $^

lex.yy.o: lex.yy.c y.tab.h
	$(CC) $(CXXFLAGS) -c lex.yy.c

y.tab.o: y.tab.c
	$(CC) $(CXXFLAGS) -c y.tab.c

$(LIBDIR)/1805097_SymbolTable.o: $(STDIR)/1805097_SymbolTable.cpp $(LIBDIR)/1805097_ScopeTable.o $(STDIR)/1805097_SymbolTable.h
	$(CC) $(CXXFLAGS) -c $< -o $@

$(LIBDIR)/1805097_ScopeTable.o: $(STDIR)/1805097_ScopeTable.cpp $(LIBDIR)/1805097_SymbolInfo.o $(STDIR)/1805097_ScopeTable.h
	$(CC) $(CXXFLAGS) -c $< -o $@

$(LIBDIR)/1805097_SymbolInfo.o: $(STDIR)/1805097_SymbolInfo.cpp $(STDIR)/1805097_SymbolInfo.h
	$(CC) $(CXXFLAGS) -c $< -o $@

$(LIBDIR)/NonTerminalInfo.o: $(UTILDIR)/NonTerminalInfo.cpp $(UTILDIR)/NonTerminalInfo.h
	$(CC) $(CXXFLAGS) -c $< -o $@

lex.yy.c: 1805097.l
	$(LC) $(LCFLAGS) 1805097.l

y.tab.c y.tab.h: 1805097.y
	$(YC) $(YCFLAGS) 1805097.y

clean:
	rm a.out lex.yy.c lex.yy.o y.tab.c y.tab.h y.tab.o code.asm optimized_code.asm

clean_all:
	rm a.out lex.yy.c lex.yy.o y.tab.c y.tab.h y.tab.o code.asm optimized_code.asm $(LIBDIR)/*.o
*/
