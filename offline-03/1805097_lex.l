%option noyywrap

%x CHAR_STATE
%x STR_STATE
%x SL_COMMENT_STATE
%x ML_COMMENT_STATE

%{
    #include "lib/src/SymbolTable/1805097_SymbolTable.h"
    #include "lib/src/util/NonTerminalInfo.h"
    #include "y.tab.h"
    #include <bits/stdc++.h>
    #include <fstream>
    #include <vector>

    #define BUCKET_SIZE 7

    using namespace std;

    int line_count=1;
    int error_count = 0;

    // string LOG_FILENAME = "1805097_log.txt";
    // string TOKEN_FILENAME = "1805097_token.txt";

    // ofstream log_stream(LOG_FILENAME);
    // ofstream token_stream(TOKEN_FILENAME);

    extern ofstream log_stream;
    extern ofstream token_stream;

    // extern YYSTYPE yylval;
    extern SymbolTable * symbolTable;

    string char_buff;
    string chars;
    int char_len=0;

    string sl_comment_buff;
    int sl_nl_count = 0;

    string ml_comment_buff;
    int ml_nl_count = 0;

    string str_buff;
    string str;
    int str_len=0;
    int str_nl_count=0;

    string to_upper(char * arg) {
        string ret(arg);
        for (int i = 0; i < ret.size(); i++) ret[i] = ret[i] & (~(1<<5));
        return ret;
    }

%}

WHITESPACE [ \t\f\r\v]+
LETTER [a-zA-Z_]
DIGIT [0-9]
NEWLINE \n
ALPHANUM [a-zA-Z_0-9]

%%

{WHITESPACE} {
	// do nothing
}

"int" {
    // log_stream<<endl<<"Line no "<<line_count<<": Token <" << to_upper(yytext) << "> Lexeme "<< yytext <<" found"<<endl;
	// token_stream<<"<"<< to_upper(yytext) <<"> ";

    return INT;
}

"float" {
    // log_stream<<endl<<"Line no "<<line_count<<": Token <" << to_upper(yytext) << "> Lexeme "<< yytext <<" found"<<endl;
	// token_stream<<"<"<< to_upper(yytext) <<"> ";

    return FLOAT;
}

"void" {
    // log_stream<<endl<<"Line no "<<line_count<<": Token <" << to_upper(yytext) << "> Lexeme "<< yytext <<" found"<<endl;
	// token_stream<<"<"<< to_upper(yytext) <<"> ";

    return VOID;
}

"if"|"for"|"do"|"switch"|"default"|"else"|"while"|"break"|"char"|"double"|"return"|"case"|"continue" {
	log_stream<<endl<<"Line no "<<line_count<<": Token <" << to_upper(yytext) << "> Lexeme "<< yytext <<" found"<<endl;
	token_stream<<"<"<< to_upper(yytext) <<"> ";
}


{DIGIT}+ {
	// log_stream<<endl<<"Line no "<<line_count<<": Token <" << "CONST_INT" << "> Lexeme "<< yytext <<" found"<<endl;
	// token_stream<<"<"<< "CONST_INT" << ", " << yytext <<"> ";
    SymbolInfo* si = new SymbolInfo((string)yytext, (string)"CONST_INT");
    if (symbolTable->insert(si)) {
        // symbolTable->printAllScopeTable(log_stream);
    } else {
        // log_stream<<endl<< yytext << " already exists in current ScopeTable" << endl;
    }
    yylval.symbolInfo = si;
    return CONST_INT;
}

{DIGIT}*(\.{DIGIT}*)?(E[\+\-]?{DIGIT}+)? {
    log_stream<<endl<<"Line no "<<line_count<<": Token <" << "CONST_FLOAT" << "> Lexeme "<< yytext <<" found"<<endl;
	token_stream<<"<"<< "CONST_FLOAT" << ", " << yytext <<"> ";
    if (symbolTable->insert(yytext, "CONST_FLOAT")) {
        symbolTable->printAllScopeTable(log_stream);
    } else {
        log_stream<<endl<< yytext << " already exists in current ScopeTable" << endl;
    }
}

{DIGIT}*(\.{DIGIT}*)(\.{DIGIT}*)+{ALPHANUM}* {
    log_stream<<endl<<"Error at line no "<< line_count <<": Too many decimal points "<<yytext<<endl;
    error_count++;
}

{DIGIT}*(\.{DIGIT}+)?(E[\+\-]?{ALPHANUM}*(\.{ALPHANUM}*)+) {
    log_stream<<endl<<"Error at line no "<< line_count <<": Ill formed number "<<yytext<<endl;
    error_count++;
}

"'" {
    char_buff.clear();
    char_buff+="'";
    chars.clear();
    char_len = 0;
    BEGIN CHAR_STATE;
}

<CHAR_STATE>(\r)?\n {
    log_stream<<endl<<"Error at line no "<< line_count <<": Unterminated character "<<char_buff<<endl;
    error_count++;
    char_buff.clear();
    chars.clear();
    line_count++;
    BEGIN INITIAL;
}

<CHAR_STATE><<EOF>> {
    log_stream<<endl<<"Error at line no "<< line_count <<": Unterminated character "<<char_buff<<endl;
    error_count++;
    char_buff.clear();
    chars.clear();
    // line_count++;
    BEGIN INITIAL;
}

<CHAR_STATE>"\\a"|"\\b"|"\\e"|"\\f"|"\\n"|"\\r"|"\\t"|"\\v"|"\\\\"|"\\'"|"\\\""|"\\?" {
    char_len++;
    switch(yytext[1]) {
        case 'a':
            // chars+=0x07;
            chars+="\a";
            break;
        case 'b':
            // chars+=0x08;
            chars+="\b";
            break;
        case 'e':
            // chars+=0x1B;
            chars+="\e";
            break;
        case 'f':
            // chars+=0x0C;
            chars+="\f";
            break;
        case 'n':
            // chars+=0x0A;
            chars+="\n";
            break;
        case 'r':
            // chars+=0x0D;
            chars+="\r";
            break;
        case 't':
            // chars+=0x09;
            chars+="\t";
            break;
        case 'v':
            // chars+=0x0B;
            chars+="\v";
            break;
        case '\\':
            chars+="\\";
            break;
        case '\'':
            chars+="'";
            break;
        case '\"':
            chars+="\"";
            break;
        case '?':
            chars+="?";
            break;
    }
    char_buff+=yytext;
}

<CHAR_STATE>"\\"{DIGIT}+ {
    string temp(yytext);
    temp = temp.substr(1, temp.size()-1);
    unsigned num = stoi(temp, nullptr, 8);
    char_buff+=yytext;
    if (num > 0xFF) {
        // recheck. what should you do when you cannot put it in one byte
        log_stream<<endl<<"Error at line no "<< line_count <<": Multi character constant error "<<char_buff<<endl;
        error_count++;
        char_buff.clear();
        chars.clear();
        BEGIN INITIAL;
    } else {
        char_len++;
        chars.append(1, (char)num);
    }
}

<CHAR_STATE>"\\x"{DIGIT}+ {
    string temp(yytext);
    temp = temp.substr(1, temp.size()-1);
    unsigned num = stoi(temp, nullptr, 16);
    char_buff+=yytext;
    if (num > 0xFF) {
        // recheck. what should you do when you cannot put it in one byte
        log_stream<<endl<<"Error at line no "<< line_count <<": Multi character constant error "<<char_buff<<endl;
        error_count++;
        char_buff.clear();
        chars.clear();
        BEGIN INITIAL;
    } else {
        char_len++;
        chars.append(1, (char)num);
    }
}

<CHAR_STATE>"\\". {
    // if escape secuence dont match then use the char followed by \ and ignore the \
    char_len++;
    char_buff+=yytext;
    chars.append(1,  yytext[1]);
}

<CHAR_STATE>"'" {
    char_buff+="'";
    if(char_len == 0) {
        log_stream<<endl<<"Error at line no "<<line_count<<": Empty character constant error ''"<<endl;
        error_count++;
    } else if(char_len > 1) {
        log_stream<<endl<<"Error at line no "<<line_count<<": Multi character constant error "<<char_buff<<endl;
        error_count++;
    } else {
        log_stream<<endl<<"Line no "<<line_count<<": Token <" << "CONST_CHAR" << "> Lexeme "<< char_buff <<" found --> <CONST_CHAR,  "<<chars<<">"<<endl;
	    token_stream<<"<"<< "CONST_CHAR" << ", " << chars <<"> ";
        if (symbolTable->insert(char_buff, "CHAR_CONST")) {
            symbolTable->printAllScopeTable(log_stream);
        } else {
            log_stream<<endl<< char_buff << " already exists in current ScopeTable" << endl;
        }
    }

    char_buff.clear();
    chars.clear();
    BEGIN INITIAL;
}

<CHAR_STATE>. {
    char_buff+=yytext;
    chars+=yytext;
    char_len++;
}


"++"|"--" {
    log_stream<<endl<<"Line no "<<line_count<<": Token <" << "INCOP" << "> Lexeme "<< yytext <<" found"<<endl;
	token_stream<<"<"<< "INCOP" << ", " << yytext <<"> ";
}

"+"|"-" {
    log_stream<<endl<<"Line no "<<line_count<<": Token <" << "ADDOP" << "> Lexeme "<< yytext <<" found"<<endl;
	token_stream<<"<"<< "ADDOP" << ", " << yytext <<"> ";
}

"*"|"/"|"%" {
    log_stream<<endl<<"Line no "<<line_count<<": Token <" << "MULOP" << "> Lexeme "<< yytext <<" found"<<endl;
	token_stream<<"<"<< "MULOP" << ", " << yytext <<"> ";
}

"<"|"<="|">"|">="|"=="|"!=" {
    log_stream<<endl<<"Line no "<<line_count<<": Token <" << "RELOP" << "> Lexeme "<< yytext <<" found"<<endl;
	token_stream<<"<"<< "RELOP" << ", " << yytext <<"> ";
}

"=" {
    log_stream<<endl<<"Line no "<<line_count<<": Token <" << "ASSIGNOP" << "> Lexeme "<< yytext <<" found"<<endl;
	token_stream<<"<"<< "ASSIGNOP" << ", " << yytext <<"> ";
}

"&&"|"||" {
    log_stream<<endl<<"Line no "<<line_count<<": Token <" << "LOGICOP" << "> Lexeme "<< yytext <<" found"<<endl;
	token_stream<<"<"<< "LOGICOP" << ", " << yytext <<"> ";
}

"!" {
    log_stream<<endl<<"Line no "<<line_count<<": Token <" << "NOT" << "> Lexeme "<< yytext <<" found"<<endl;
	token_stream<<"<"<< "NOT" << ", " << yytext <<"> ";
}

"(" {
    log_stream<<endl<<"Line no "<<line_count<<": Token <" << "LPAREN" << "> Lexeme "<< yytext <<" found"<<endl;
	token_stream<<"<"<< "LPAREN" << ", " << yytext <<"> ";
}

")" {
    log_stream<<endl<<"Line no "<<line_count<<": Token <" << "RPAREN" << "> Lexeme "<< yytext <<" found"<<endl;
	token_stream<<"<"<< "RPAREN" << ", " << yytext <<"> ";
}

"[" {
    // log_stream<<endl<<"Line no "<<line_count<<": Token <" << "LTHIRD" << "> Lexeme "<< yytext <<" found"<<endl;
	// token_stream<<"<"<< "LTHIRD" << ", " << yytext <<"> ";

    return LTHIRD;
}

"]" {
    // log_stream<<endl<<"Line no "<<line_count<<": Token <" << "RTHIRD" << "> Lexeme "<< yytext <<" found"<<endl;
	// token_stream<<"<"<< "RTHIRD" << ", " << yytext <<"> ";

    return RTHIRD;
}

"," {
    // log_stream<<endl<<"Line no "<<line_count<<": Token <" << "COMMA" << "> Lexeme "<< yytext <<" found"<<endl;
	// token_stream<<"<"<< "COMMA" << ", " << yytext <<"> ";

    return COMMA;
}

";" {
    // log_stream<<endl<<"Line no "<<line_count<<": Token <" << "SEMICOLON" << "> Lexeme "<< yytext <<" found"<<endl;
	// token_stream<<"<"<< "SEMICOLON" << ", " << yytext <<"> ";

    return SEMICOLON;
}

"{" {
    log_stream<<endl<<"Line no "<<line_count<<": Token <" << "LCURL" << "> Lexeme "<< yytext <<" found"<<endl;
	token_stream<<"<"<< "LCURL" << ", " << yytext <<"> ";
    symbolTable->enterScope();
}

"}" {
    log_stream<<endl<<"Line no "<<line_count<<": Token <" << "RCURL" << "> Lexeme "<< yytext <<" found"<<endl;
	token_stream<<"<"<< "RCURL" << ", " << yytext <<"> ";
    symbolTable->exitScope();
}




(\r)?\n {
    line_count++;
}




{LETTER}+{ALPHANUM}* {
    // log_stream<<endl<<"Line no "<<line_count<<": Token <" << "ID" << "> Lexeme "<< yytext <<" found"<<endl;
	// token_stream<<"<"<< "ID" << ", " << yytext <<"> ";

    // if (symbolTable->insert(yytext, "ID")) {
    //     // symbolTable->printAllScopeTable(log_stream);
    // } else {
    //     // log_stream<<endl<< yytext << " already exists in current ScopeTable" << endl;
    // }

    yylval.symbolInfo = new SymbolInfo(yytext, "ID");
    return ID;
}


{ALPHANUM}+ {
    log_stream<<endl<<"Error at line no "<< line_count <<": Invalid prefix on ID or invalid suffix on Number "<< yytext <<endl;
    error_count++;
}

"\"" {
    BEGIN STR_STATE;
    str_buff.clear();
    str.clear();
    str_len = 0;
    str_nl_count = 0;
    str_buff+=yytext;
}

<STR_STATE>(\r)?\n {
    log_stream<<endl<<"Error at line no "<< line_count - str_nl_count <<": Unterminated String "<<str_buff<<endl;
    error_count++;
    str_buff.clear();
    str.clear();
    str_len = 0;
    str_nl_count = 0;
    line_count++;
    BEGIN INITIAL;
}

<STR_STATE>"\\"{WHITESPACE}*(\r)?\n {
    str_buff+=yytext;
    line_count++;
    str_nl_count++;
}

<STR_STATE><<EOF>> {
    log_stream<<endl<<"Error at line no "<< line_count - str_nl_count <<": Unterminated String "<<str_buff<<endl;
    error_count++;
    str_buff.clear();
    str.clear();
    str_len = 0;
    str_nl_count=0;
    // line_count++;
    BEGIN INITIAL;
}

<STR_STATE>"\\a"|"\\b"|"\\e"|"\\f"|"\\n"|"\\r"|"\\t"|"\\v"|"\\\\"|"\\'"|"\\\""|"\\?" {
    str_len++;
    str_buff+=yytext;
    switch(yytext[1]) {
        case 'a':
            // chars+=0x07;
            str+="\a";
            break;
        case 'b':
            // chars+=0x08;
            str+="\b";
            break;
        case 'e':
            // chars+=0x1B;
            str+="\e";
            break;
        case 'f':
            // chars+=0x0C;
            str+="\f";
            break;
        case 'n':
            // chars+=0x0A;
            str+="\n";
            break;
        case 'r':
            // chars+=0x0D;
            str+="\r";
            break;
        case 't':
            // chars+=0x09;
            str+="\t";
            break;
        case 'v':
            // chars+=0x0B;
            str+="\v";
            break;
        case '\\':
            str+="\\";
            break;
        case '\'':
            str+="'";
            break;
        case '\"':
            str+="\"";
            break;
        case '?':
            str+="?";
            break;
    }
    
}

<STR_STATE>"\\"{DIGIT}+ {
    string temp(yytext);
    temp = temp.substr(1, temp.size()-1);
    unsigned num = stoi(temp, nullptr, 8);
    str_buff+=yytext;
    if (num > 0xFF) {
        // recheck. what should you do when you cannot put it in one byte
        log_stream<<endl<<"Error at line no "<< line_count - str_nl_count <<": Multi character constant error "<<str_buff<<endl;
        error_count++;
        str_buff.clear();
        BEGIN INITIAL;
    } else {
        str_len++;
        str.append(1, (char)num);
    }
}

<STR_STATE>"\\x"{DIGIT}+ {
    string temp(yytext);
    temp = temp.substr(1, temp.size()-1);
    unsigned num = stoi(temp, nullptr, 16);
    str_buff+=yytext;
    if (num > 0xFF) {
        // recheck. what should you do when you cannot put it in one byte
        log_stream<<endl<<"Error at line no "<< line_count - str_nl_count <<": Multi character constant error "<<str_buff<<endl;
        error_count++;
        str_buff.clear();
        BEGIN INITIAL;
    } else {
        str_len++;
        str.append(1, (char)num);
    }
}

<STR_STATE>"\\". {
    // if escape secuence dont match then use the char followed by \ and ignore the \
    str_len++;
    str_buff+=yytext;
    str.append(1, yytext[1]);
}

<STR_STATE>"\"" {
    str_buff+=yytext;
    log_stream<<endl<<"Line no "<< line_count - str_nl_count <<": Token <STRING> Lexeme "<< str_buff <<" found --> <STRING, \""<< str <<"\">" << endl;
    token_stream<<"<STRING, \""<<str<<"\"> ";
    str_buff.clear();
    str.clear();
    str_len = 0;
    BEGIN INITIAL;
}

<STR_STATE>. {
    str_buff+=yytext;
    str+=yytext;
    str_len++;
}


"//" {
    sl_comment_buff.clear();
    sl_comment_buff+=yytext;
    sl_nl_count = 0;
    BEGIN SL_COMMENT_STATE;
}

<SL_COMMENT_STATE>"\\"(\r)?\n {
    sl_comment_buff+=yytext;
    sl_nl_count++;
    line_count++;
}

<SL_COMMENT_STATE>(\r)?(\n) {
    BEGIN INITIAL;
    log_stream<<endl<<"Line no "<< line_count - sl_nl_count <<": Token <COMMENT> Lexeme "<<sl_comment_buff<<" found"<<endl;
    sl_nl_count=0;
    sl_comment_buff.clear();
    line_count++;
}

<SL_COMMENT_STATE>. {
    sl_comment_buff+=yytext;
}

"/*" {
    ml_comment_buff.clear();
    ml_comment_buff+=yytext;
    ml_nl_count = 0;
    BEGIN ML_COMMENT_STATE;
}

<ML_COMMENT_STATE>(\r)?(\n) {
    ml_comment_buff+=yytext;
    ml_nl_count++;
    line_count++;
}

<ML_COMMENT_STATE>"*/" {
    ml_comment_buff+=yytext;
    log_stream<<endl<<"Line no "<< line_count - ml_nl_count <<": Token <COMMENT> Lexeme "<<ml_comment_buff<<" found"<<endl;
    ml_comment_buff.clear();
    ml_nl_count++;
    BEGIN INITIAL;
}

<ML_COMMENT_STATE><<EOF>> {
    log_stream<<endl<<"Error at line no "<<line_count-ml_nl_count<<": Unterminated Comment "<<ml_comment_buff<<endl;
    error_count++;
    ml_comment_buff.clear();
    ml_nl_count = 0;
    BEGIN INITIAL;
}

<ML_COMMENT_STATE>. {
    ml_comment_buff+=yytext;
}


. {
    log_stream<<endl<<"Error at line no "<< line_count <<": Unrecognized character "<< yytext <<endl;
    error_count++;
}

%%

// int main(int argc, char *argv[]){

// 	if(argc!=2){
// 		printf("Please provide input file name and try again\n");
// 		return 0;
// 	}

// 	FILE *fin=fopen(argv[1], "r");
// 	if(fin==NULL){
// 		printf("Cannot open specified file\n");
// 		return 0;
// 	}

//     symbolTable = new SymbolTable(BUCKET_SIZE);

// 	yyin= fin;
// 	yylex();

//     symbolTable->printAllScopeTable(log_stream);

//     log_stream<<endl<<"Total lines: "<<line_count<<endl;
//     log_stream<<"Total errors: "<<error_count<<endl;
// 	fclose(yyin);
//     log_stream.close();
//     token_stream.close();
//     delete symbolTable;
// 	return 0;
// }
