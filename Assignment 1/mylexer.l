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

int num_lines = 0;

// const char* tokenStr[] = {};
	struct var
	{
		string Name;
		void *Value;
		int Type;
		struct var *Next;
	};

	class Var_list
	{
		public:
			struct var *head;
			int max;
			struct var *temp;
			Var_list()
			{
				max = 0;
			}
			int set_var(char* name)
			{
				string s_name = name;
				this->temp = this->head;
				//查看该变量是否已经存在
				int i = max;
				while( this->temp != NULL)
				{
					i--;
					if( temp->Name == s_name )
					{
						return i;
					}
					temp = temp->Next;
				}
				this->temp = this->head;
				this->head = new struct var;
				this->head->Name = s_name;
				this->head->Next = temp;
				max++;
				
				return max-1;
			}
	}m_list;

// 

static void print_token(string token, char* text)
{
	// cout<<1;
	if(token == "SEMICOLON")
		cout<<token<<"\t\t"<<text<<"\t\t";
	else cout<<token<<"\t\t\t"<<text<<"\t\t";
	if(token == "ID")
	{
		cout<<m_list.set_var(text)<<"\t";
	}
	if(token == "NUMBER")
	{
		cout<<text<<"\t";
	}
	cout<<endl;
}
%}

/////////////////////////////////////////////////////////////////////////////
// declarations section

MAIN	"main"
INT 	"int"
CHAR 	"char"
IF 		"if"
ELSE 	"else"
WHILE 	"while"
FOR 	"for"

ID		[_a-zA-Z][_a-zA-Z0-9]*

NUMBER	[0-9]+

LBRACE 	"{"
RBRACE 	"}"
LPAREN 	"("
RPAREN 	")"
LBRACKET "["
RBRACKET "]"

ASSIGN 	"="
ADD 	"+"
SUB 	"-"
MUL 	"*"
DIV 	"/"
MOD 	"%"
INC 	"++"
DEC 	"--"
EQ 		"=="

SEMICOLON 	";"



// lexical analyser name
%name mylexer

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

// place any declarations here

%%

/////////////////////////////////////////////////////////////////////////////
// rules section



// place your Lex rules here
" "			{}
"\n"    	{++num_lines;}
"\t"		{}
""
{MAIN}		{print_token("MAIN", yytext);}
{INT}		{print_token("INT", yytext);}
{CHAR} 		{print_token("CHAR", yytext);}
{IF} 		{print_token("IF", yytext);}
{ELSE}		{print_token("ELSE", yytext);}
{WHILE} 	{print_token("WHILE", yytext);}
{FOR} 		{print_token("FOR", yytext);}
{ID}		{print_token("ID", yytext);}

{NUMBER}	{print_token("NUMBER", yytext);}

{LBRACE} 	{print_token("LBRACE", yytext);}
{RBRACE} 	{print_token("RBRACE", yytext);}
{LPAREN} 	{print_token("LPAREN", yytext);}
{RPAREN} 	{print_token("RPAREN", yytext);}
{LBRACKET} 	{print_token("LBRACKET", yytext);}
{RBRACKET} 	{print_token("RBRACKET", yytext);}

{ASSIGN}	{print_token("ASSIGN", yytext);}
{ADD} 		{print_token("ADD", yytext);}
{SUB} 		{print_token("SUB", yytext);}
{MUL} 		{print_token("MUL", yytext);}
{DIV} 		{print_token("DIV", yytext);}
{MOD} 		{print_token("MOD", yytext);}
{INC} 		{print_token("INC", yytext);}
{DEC} 		{print_token("DEC", yytext);}
{EQ}		{print_token("EQ", yytext);}

{SEMICOLON} {print_token("SEMICOLON", yytext);}


%%

/////////////////////////////////////////////////////////////////////////////
// programs section

int main()
{
	cout<<"WORD     \t\t"<<"MORPHEME\t"<<"ATTRIBUTES\t"<<endl<<endl;
	int n = 1;
	mylexer lexer;
	if (lexer.yycreate()) {
		freopen("test.txt","r",stdin);
		n = lexer.yylex();
		freopen("CON","r",stdin);
	}
	system("pause");
	return n;
}
