%{
/****************************************************************************
mylexer.l
ParserWizard generated Lex file.

Date: 2018��11��1��
****************************************************************************/

#define _CRT_SECURE_NO_WARNINGS
#pragma warning(disable:4996)
#include "myparser.h"
#include <iostream>

#include <fstream>
#include <string>
using namespace std;

string token_text = "Hello";

int num_lines = 1;



%}

/////////////////////////////////////////////////////////////////////////////
// declarations section

//语句类型

MAIN	"main"
INT 	"int"
CHAR 	"char"
IF 		"if"
ELSE 	"else"
WHILE 	"while"
FOR 	"for"

STR 	\"[^\"]*\"
LETTER	'[^'\n]'
ANNOTATION 		(\/\*(".*"|[^\*"]|(\*)+[^\/])*(\*)*\*\/)|(\/\/[^\n]*)
ANNOTATIONO   \/\/.*\n

ID		[_a-zA-Z][_a-zA-Z0-9]*

NUMBER	[0-9]+

LBRACE 	"{"
RBRACE 	"}"
LPAREN 	"("
RPAREN 	")"
LBRACKET "["
RBRACKET "]"

//运算符

//基本：


ASSIGN 	"="
ADD 	"+"
SUB 	"-"
MUL 	"*"
DIV 	"/"
MOD 	"%"
INC 	"++"
DEC 	"--"
//进阶：


B_AND	"&"
B_IOR 	"|"
B_EOR 	"^"
B_OPP 	"~"
M_LEFT 	"<<"
M_RIGHT 	">>"

EQ 		"=="
GRT 	">"
LET 	"<"
GRE 	">="
LEE 	"<="
NE 		"!="

AND 	"&&"
OR 		"||"
NOT 	"!"

COMMA	","
SEMICOLON 	";"



// lexical analyser name
%name mylexer

// class definition
{
	// place any extra class members here
	public:
	static int getToken();
}

// constructor
{
	// place any extra initialisation code here
}

// destructor
{
	// place any extra cleanup code here
}

// place any declarations here

%%

/////////////////////////////////////////////////////////////////////////////
// rules section



// place your Lex rules here
" "			{}
"\n"    	{++num_lines;}
"\t"		{}
""			{}
{MAIN}		{return MAIN;}
{INT}		{return INT;}
{CHAR} 		{return CHAR;}
{IF} 		{return IF;}
{ELSE}		{return ELSE;}
{WHILE} 	{return WHILE;}
{FOR} 		{return FOR;}

{STR}		{return STR;}
{LETTER}	{token_text = yytext;return LETTER;}
{ANNOTATION}	{}
{ANNOTATIONO}	{}

{ID}		{token_text = yytext;return ID;}

{NUMBER}	{token_text = yytext;return NUMBER;}

{LBRACE} 	{return LBRACE;}
{RBRACE} 	{return RBRACE;}
{LPAREN} 	{return LPAREN;}
{RPAREN} 	{return RPAREN;}
{LBRACKET} 	{return LBRACKET;}
{RBRACKET} 	{return RBRACKET;}

{ASSIGN}	{return ASSIGN;}
{ADD} 		{return ADD;}
{SUB} 		{return SUB;}
{MUL} 		{return MUL;}
{DIV} 		{return DIV;}
{MOD} 		{return MOD;}
{INC} 		{return INC;}
{DEC} 		{return DEC;}

{B_AND}		{return B_AND;}
{B_IOR} 	{return B_IOR;}
{B_EOR} 	{return B_EOR;}
{B_OPP} 	{return B_OPP;}
{M_LEFT} 	{return M_LEFT;}
{M_RIGHT} 	{return M_RIGHT;}

{EQ}		{return EQ;}
{GRT} 		{return GRT;}
{LET} 		{return LET;}
{GRE} 		{return GRE;}
{LEE} 		{return LEE;}
{NE} 		{return NE;}

{AND} 		{return AND;}
{OR} 		{return OR;}
{NOT} 		{return NOT;}

{COMMA}		{return COMMA;}
{SEMICOLON} {return SEMICOLON;}


%%

/////////////////////////////////////////////////////////////////////////////
// programs section
