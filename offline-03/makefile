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

lex.yy.c: 1805097_lex.l
	$(LC) $(LCFLAGS) 1805097_lex.l

y.tab.c y.tab.h: parser.y
	$(YC) $(YCFLAGS) parser.y

clean:
	rm a.out lex.yy.c lex.yy.o y.tab.c y.tab.h y.tab.o

clean_all:
	rm a.out lex.yy.c lex.yy.o y.tab.c y.tab.h y.tab.o $(LIBDIR)/*.o