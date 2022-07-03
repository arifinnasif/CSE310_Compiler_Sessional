%{
#include<bits/stdc++.h>
#include<iostream>
#include<cstdlib>
#include<cstring>
#include<cmath>
#include<vector>
#include "lib/src/SymbolTable/1805097_SymbolTable.h"
#include "lib/src/util/NonTerminalInfo.h"
// #define YYSTYPE SymbolInfo*

using namespace std;

int yyparse(void);
int yylex(void);
extern FILE *yyin;
extern int line_count;
FILE *fp, *fp2, *fp3;

SymbolTable *symbolTable;

string LOG_FILENAME = "1805097_log.txt";
string TOKEN_FILENAME = "1805097_token.txt";

ofstream log_stream;
ofstream error_stream;
ofstream token_stream(TOKEN_FILENAME);


void yyerror(char *s)
{
	//write your code
}

void log(string type, string message) {
	if(type == "production") {
		// cout<<message<<endl;
		log_stream<<"Line "<<line_count<<": "<<message<<endl<<endl;
		// fprintf(fp2,"Line %d: %s\n\n",line_count, message);
	} else if (type == "matched") {
		log_stream<<message<<endl<<endl;
	}
}

void err(string type, string message) {
	log_stream<<"Error at line "<<line_count<<": ";
	error_stream<<"Error at line "<<line_count<<": ";
	if(type == "multi_dec") {
		log_stream<<"Multiple declaration of "<<message<<endl<<endl;
		error_stream<<"Multiple declaration of "<<message<<endl<<endl;
	} else if(type == "var_void") {
		log_stream<<"Variable type cannot be void"<<endl<<endl;
		error_stream<<"Variable type cannot be void"<<endl<<endl;
	}
}



%}

%union {
	SymbolInfo * symbolInfo;
	NonTerminalInfo * nonTerminalInfo;
	//std::vector<SymbolInfo*> * vector_declaration_list;
}

%token IF ELSE FOR WHILE DO BREAK INT CHAR FLOAT DOUBLE VOID RETURN SWITCH CASE DEFAULT CONTINUE
%token <symbolInfo> CONST_INT CONST_FLOAT CONST_CHAR
%token ADDOP MULOP INCOP DECOP RELOP ASSIGNOP LOGICOP NOT LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON
%token <symbolInfo> STRING
%token PRINTLN
%token <symbolInfo> ID

%type <nonTerminalInfo> variable start program unit func_declaration func_definition
%type <nonTerminalInfo> type_specifier declaration_list parameter_list compound_statement statements
%type <nonTerminalInfo> var_declaration statement expression_statement
%type <nonTerminalInfo> logic_expression rel_expression simple_expression term
%type <nonTerminalInfo> unary_expression factor argument_list arguments
//%type <vector_declaration_list> 

%start start

// %left 
// %right

// %nonassoc 


%%

start : program
	{
		//write your code in this block in all the similar blocks below
		log("production", "start : program");

		
		log("matched", $$->name);
	}
	;

program : program unit {
		log("production", "program : unit");

		$$->name = $1->name + $2->name;
		log("matched", $$->name);
	}
	| unit {
		log("production", "program : unit");

		$$->name = $1->name + "\n";
		log("matched", $$->name);
	}
	;
	
unit : var_declaration {
	log("production", "unit : var_declaration");

	
	log("matched", $$->name);
}
     | func_declaration
     | func_definition
     ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON
		| type_specifier ID LPAREN RPAREN SEMICOLON
		;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement
		| type_specifier ID LPAREN RPAREN compound_statement
 		;				


parameter_list  : parameter_list COMMA type_specifier ID
		| parameter_list COMMA type_specifier
 		| type_specifier ID
		| type_specifier
 		;

 		
compound_statement : LCURL statements RCURL
 		    | LCURL RCURL
 		    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON {
		///
		if($1->name == "void") {
			err("var_void", "");
		}

		log("production", "var_declaration : type_specifier declaration_list SEMICOLON");


		for(auto i : $2 -> vector_si) {
			
			if(!i->isError) {
				i->setDataType($1->name);
			}
		}

		$$->name = $1-> name + " " + $2-> name + ";";

		log("matched", $$->name);
		}
 		 ;
 		 
type_specifier	: INT {
			log("production", "type_specifier	: INT");
			
			$$ = new NonTerminalInfo();
			$$->setName("int");

			log("matched", $$->name);
		}
 		| FLOAT {
			log("production", "type_specifier	: FLOAT");

			$$ = new NonTerminalInfo();
			$$->setName("float");

			log("matched", $$->name);
		}
 		| VOID {
			log("production", "type_specifier	: VOID");

			$$ = new NonTerminalInfo();
			$$->setName("void");

			log("matched", $$->name);
		}
 		;
 		
declaration_list : declaration_list COMMA ID {	
			if($3->isError = !symbolTable->insert($3)) {
				err("multi_dec", $3->getName());
			}

			log("production", "declaration_list : declaration_list COMMA ID");
			
			$$ = $1;
			$$->name += ", " + $3->getName();
			$$->vector_si.push_back($3);

			log("matched", $$->name);
		}
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD {
			
			if($3->isError = !symbolTable->insert($3)) {
				err("multi_dec", $3->getName());
			}

			log("production", "declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD");

			$$ = $1;
			$$->name += ", " + $3->getName() + "[" + $5->getName() + "]";
			$3-> setAsArray(atoi($5->getName().c_str()));
			$$->vector_si.push_back($3);

			log("matched", $$->name);
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
		  }
 		  | ID LTHIRD CONST_INT RTHIRD {
			
			if($1->isError = !symbolTable->insert($1)) {
				err("multi_dec", $1->getName());
			}

			log("production", "declaration_list : ID LTHIRD CONST_INT RTHIRD");

			$$ = new NonTerminalInfo();
			$$->name = $1->getName() + "[" + $3->getName() + "]";
			$1-> setAsArray(atoi($3->getName().c_str()));
			$$->vector_si.push_back($1);

			log("matched", $$->name);
		  }
 		  ;
 		  
statements : statement
	   | statements statement
	   ;
	   
statement : var_declaration
	  | expression_statement
	  | compound_statement
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement
	  | IF LPAREN expression RPAREN statement
	  | IF LPAREN expression RPAREN statement ELSE statement
	  | WHILE LPAREN expression RPAREN statement
	  | PRINTLN LPAREN ID RPAREN SEMICOLON
	  | RETURN expression SEMICOLON
	  ;
	  
expression_statement 	: SEMICOLON			
			| expression SEMICOLON 
			;
	  
variable : ID 		{
	log("production", "variable : ID");

	$$ = new NonTerminalInfo();
	$$->setName($1->getName());

	log("matched", $$->name);
}
	 | ID LTHIRD expression RTHIRD
	 ;
	 
 expression : logic_expression	
	   | variable ASSIGNOP logic_expression 	
	   ;
			
logic_expression : rel_expression 	
		 | rel_expression LOGICOP rel_expression 	
		 ;
			
rel_expression	: simple_expression 
		| simple_expression RELOP simple_expression	
		;
				
simple_expression : term 
		  | simple_expression ADDOP term 
		  ;
					
term :	unary_expression
     |  term MULOP unary_expression
     ;

unary_expression : ADDOP unary_expression  
		 | NOT unary_expression 
		 | factor 
		 ;
	
factor	: variable 
	| ID LPAREN argument_list RPAREN
	| LPAREN expression RPAREN
	| CONST_INT 
	| CONST_FLOAT
	| variable INCOP 
	| variable DECOP
	;
	
argument_list : arguments
			  |
			  ;
	
arguments : arguments COMMA logic_expression
	      | logic_expression
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
	log_stream.open(argv[2]);
	error_stream.open(argv[3]);

	symbolTable = new SymbolTable(32);
	

	yyin=fp;
	yyparse();
	

	// fclose(fp2);
	// fclose(fp3);

	log_stream.close();
	error_stream.close();
	
	return 0;
}

