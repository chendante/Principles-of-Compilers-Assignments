%{
/****************************************************************************
myparser.y
ParserWizard generated YACC file.

Date: 2018��11��1��
****************************************************************************/
#define  _CRT_SECURE_NO_WARNINGS
#include "mylexer.h"
#include <fstream>
#include <iostream>
// #include <stdio.h>

using namespace std;




%}

/////////////////////////////////////////////////////////////////////////////
// declarations section

// parser name
%name myparser

// class definition
{
	// place any extra class members here

}

// constructor
{
	// place any extra initialisation code here
}

// destructor
{
	// place any extra cleanup code here
}

// attribute type
%include {
#ifndef YYSTYPE
#define YYSTYPE int
#endif
}

// place any declarations here

%token NUMBER	//十进制数
%token ID
%token ADD SUB // 加减
%token MUL DIV	//乘除
%token LE RE	//括号
%token MOD INC DEC

%token MAIN	INT CHAR IF ELSE WHILE FOR

%token LBRACE RBRACE LPAREN RPAREN LBRACKET RBRACKET SEMICOLON

%%

/////////////////////////////////////////////////////////////////////////////
// rules section

// place your YACC rules here (there must be at least one)

Grammar
	: /* empty */
	;

%%

/////////////////////////////////////////////////////////////////////////////
// programs section

// int main(void)
// {
// 	int n = 1;
// 	mylexer lexer;
// 	myparser parser;
// 	// parser.yycreate();
// 	if(lexer.yycreate())
// 	{
// 		freopen("a.txt","r",stdin);
// 		n = lexer.yylex();
// 		freopen("CON","r",stdin);
// 	}
// 	// if (parser.yycreate(&lexer)) {
// 	// 	if (lexer.yycreate(&parser)) {
// 	// 		n = parser.yyparse();
// 	// 	}
// 	// }
// 	return n;
// }

