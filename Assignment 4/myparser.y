%{
/****************************************************************************
myparser.y
ParserWizard generated YACC file.

Date: 2018??11??1??
****************************************************************************/
#define _CRT_SECURE_NO_WARNINGS
#pragma warning(disable:4996)
#include "mylexer.h"
#include "myparser.h"
#include "TreeNode.h"
#include <fstream>
#include <iostream>
#include <sstream>
#include <string>
#include <vector>
#include <map>

// #define MAXCHILDREN 5

using namespace std;
extern string token_text;
extern int num_lines;


int num_int = 0;
int num_char = 0;
int node_num = 0;
int tmp_var_num = 0;
int label_num = 0;
stringstream code;

TreeNode* root;
VarList m_list;

%}

/////////////////////////////////////////////////////////////////////////////
// declarations section

// parser name
%name myparser

// class definition
{
	// place any extra class members here
	// virtual int yygettoken();
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
#define YYSTYPE TreeNode*
#endif
}

// place any declarations here

%token NUMBER	//十进制数
%token ID
%token ADD SUB // 加减
%token MUL DIV	//乘除
%token MOD INC DEC
%token B_AND B_IOR B_EOR B_OPP M_LEFT M_RIGHT

%token MAIN	INT CHAR IF ELSE WHILE FOR

%token STR LETTER

%token EQ GRT LET GRE LEE NE
%token AND OR NOT 

%token LBRACE RBRACE LPAREN RPAREN LBRACKET RBRACKET SEMICOLON COMMA

%token ASSIGN INPUT OUTPUT

%token USUB



//下面的优先级高
%right ASSIGN

%left OR
%left AND  

%left B_IOR
%left B_EOR
%left B_AND
%left EQ NE
%left GRT LET GRE LEE
%left M_LEFT M_RIGHT
%left ADD SUB
%left MUL DIV MOD


//终极优先：
//负号运算符
%right USUB
%right INC DEC
%right B_OPP NOT

%%

/////////////////////////////////////////////////////////////////////////////
// rules section

// place your YACC rules here (there must be at least one)

main:	MAIN LPAREN RPAREN braced_stmt
		{
			$$ = $4;
			$$->display();
			$$->typecheckStart();
			$$->display();

			$$->genMain();
		}
		;

//被{}括住的语句

braced_stmt:	LBRACE stmts RBRACE   
			{
				$$ = TreeNode::newStmtNode(StmtsK);
				$$->children[0] = $2;
			}
			|	LBRACE	RBRACE
			{
				//$$ = NULL; 不能直接赋值NULL
				$$ = new TreeNode();
			}
			;

stmts:	stmt stmts
		{
			// $$ = TreeNode::newStmtNode(StmtsK);
			// $$->children[0] = $1;
			$$ = $1;
			$$->sibling = $2;
		}	
		|	stmt
		{
			$$ = $1;
		}
		;


stmt: decl_stmt SEMICOLON
		{
			$$ = $1;
		}
		| braced_stmt
		{
			$$ = $1;
		}
		| while_stmt
		{
			$$ = $1;
		}
		| if_stmt
		{
			$$ = $1;
		}
		| for_stmt
		{
			$$ = $1;
		}
		| expr SEMICOLON
		{
			$$ = $1;
		}
		| SEMICOLON
		{
			$$ = new TreeNode();
		}
		| input_stmt
		{
			$$ = $1;
		}
		| output_stmt
		{
			$$ = $1;
		}
		;

decl_stmt: 	type idlist
			{
				$$ = TreeNode::newStmtNode(DeclK);
				$$->children[0] = $1;
				$$->children[1] = $2;
				// 将所有idlist中的assign和id的类型都改变为当前类型
				ExpType tmp_type = $1->type;
				TreeNode* tmp_node = $2;
				while(tmp_node != NULL)
				{
					if( tmp_node->children[0] != NULL)
					{
						tmp_node->children[0]->type = tmp_type;
					}
					tmp_node->type = tmp_type;
					tmp_node = tmp_node->sibling;
				}
			}
			;

type:	INT
	{
		$$ = new TreeNode();
		$$->nodekind = TypeK;
		$$->type = Integer;
	}
	|	CHAR
	{
		$$ = new TreeNode();
		$$->nodekind = TypeK;
		$$->type = Char;
	}
	;

idlist:	id	COMMA	idlist
		{
			$$ = $1;
			$$->sibling = $3;
		}
		|	assign_stmt	COMMA idlist
		{
			$$ = $1;
			$$->sibling = $3;
		}
		|	id
		{
			$$ = $1;
		}
		|	assign_stmt
		{
			$$ = $1;
		}
		;


id: ID 
	{
		$$ = TreeNode::newIdNode(token_text);
	}
	;

//赋值语句


assign_stmt:	id ASSIGN expr
			{
				$$ = TreeNode::newStmtNode(AssignK);
				$$->children[0] = $1;
				$$->children[1] = $3;
				$$->type = Void;
			}
			;

expr: expr ADD expr
		{
			$$ = TreeNode::newDoubleNode(ADD,$1,$3);
		}
		| expr SUB expr
		{
			$$ = TreeNode::newDoubleNode(SUB,$1,$3);
		}
		| expr MUL expr
		{
			$$ = TreeNode::newDoubleNode(MUL,$1,$3);
		}
		| expr DIV expr
		{
			$$ = TreeNode::newDoubleNode(DIV,$1,$3);
		}
		| expr MOD expr
		{
			$$ = TreeNode::newDoubleNode(MOD,$1,$3);
		}
		| SUB expr %prec USUB
		{
			$$ = TreeNode::newSingleNode(USUB,$2);
		}
		| expr INC
		{
			$$ = TreeNode::newSingleNode(INC,$1);
		}
		| expr DEC
		{
			$$ = TreeNode::newSingleNode(DEC,$1);
		}
		| INC expr
		{
			$$ = TreeNode::newSingleNode(INC,$2);
		}
		| DEC expr
		{
			$$ = TreeNode::newSingleNode(DEC,$2);
		}
		| expr M_LEFT expr
		{
			$$ = TreeNode::newDoubleNode(M_LEFT,$1,$3);
		}
		| expr M_RIGHT expr
		{
			$$ = TreeNode::newDoubleNode(M_RIGHT,$1,$3);
		}
		| expr EQ expr
		{
			$$ = TreeNode::newDoubleNode(EQ,$1,$3);
		}
		| expr GRT expr
		{
			$$ = TreeNode::newDoubleNode(GRT,$1,$3);
		}
		| expr LET expr
		{
			$$ = TreeNode::newDoubleNode(LET,$1,$3);
		}
		| expr GRE expr
		{
			$$ = TreeNode::newDoubleNode(GRE,$1,$3);
		}
		| expr LEE expr
		{
			$$ = TreeNode::newDoubleNode(LEE,$1,$3);
		}
		| expr NE expr
		{
			$$ = TreeNode::newDoubleNode(NE,$1,$3);
		}
		| expr AND expr
		{
			$$ = TreeNode::newDoubleNode(AND,$1,$3);
		}
		| expr OR expr
		{
			$$ = TreeNode::newDoubleNode(OR,$1,$3);
		}
		| NOT expr
		{
			$$ = TreeNode::newSingleNode(NOT,$2);
		}
		| expr B_AND expr
		{
			$$ = TreeNode::newDoubleNode(B_AND,$1,$3);
		}
		| expr B_EOR expr
		{
			$$ = TreeNode::newDoubleNode(B_EOR,$1,$3);
		}
		| expr B_IOR expr
		{
			$$ = TreeNode::newDoubleNode(B_IOR,$1,$3);
		}
		| B_OPP expr
		{
			$$ = TreeNode::newSingleNode(B_OPP,$2);
		}
		| factor
		{
			$$ = $1;
		}
		| assign_stmt
		{
			$$ = $1;
		}
		;

factor: id
		{
			$$ = $1;
		}
		| num
		{
			$$ = $1;
		}
		| letter
		{
			$$ = $1;
		}
		| LPAREN expr RPAREN
		{
			$$ = $2;
		}
		;

num: NUMBER
	{
		$$ = TreeNode::newIntNode(token_text);
	}
	;

letter: LETTER
		{
			$$ = TreeNode::newLetterNode(token_text);
		}
		;

while_stmt: WHILE LPAREN expr RPAREN stmt
			{
				$$ = TreeNode::newStmtNode(WhileK);
				$$->children[0] = $3;
				$$->children[1] = $5;
			}
			;

if_stmt: IF LPAREN expr RPAREN stmt
		{
			$$ = TreeNode::newStmtNode(IfK);
			$$->children[0] = $3;
			$$->children[1] = $5;
		}
		| IF LPAREN expr RPAREN stmt ELSE stmt
		{
			$$ = TreeNode::newStmtNode(IfK);
			$$->children[0] = $3;
			$$->children[1] = $5;
			$$->children[2] = $7;
		}
		;

for_stmt: FOR LPAREN expr SEMICOLON expr SEMICOLON expr RPAREN stmt
		{
			$$ = TreeNode::newStmtNode(ForK);
			$$->children[0] = $3;
			$$->children[1] = $5;
			$$->children[2] = $7;
			$$->children[3] = $9;
		}
		| FOR LPAREN expr SEMICOLON expr SEMICOLON RPAREN stmt
		{
			$$ = TreeNode::newStmtNode(ForK);
			$$->children[0] = $3;
			$$->children[1] = $5;
			$$->children[3] = $8;
		}
		| FOR LPAREN expr SEMICOLON  SEMICOLON expr RPAREN stmt
		{
			$$ = TreeNode::newStmtNode(ForK);
			$$->children[0] = $3;
			$$->children[2] = $6;
			$$->children[3] = $8;
		}
		| FOR LPAREN expr SEMICOLON SEMICOLON RPAREN stmt
		{
			$$ = TreeNode::newStmtNode(ForK);
			$$->children[0] = $3;
			$$->children[3] = $7;
		}
		| FOR LPAREN SEMICOLON expr SEMICOLON expr RPAREN stmt
		{
			$$ = TreeNode::newStmtNode(ForK);
			$$->children[1] = $4;
			$$->children[2] = $6;
			$$->children[3] = $8;
		}
		| FOR LPAREN SEMICOLON expr SEMICOLON RPAREN stmt
		{
			$$ = TreeNode::newStmtNode(ForK);
			$$->children[1] = $4;
			$$->children[3] = $7;
		}
		| FOR LPAREN SEMICOLON  SEMICOLON expr RPAREN stmt
		{
			$$ = TreeNode::newStmtNode(ForK);
			$$->children[2] = $5;
			$$->children[3] = $7;
		}
		| FOR LPAREN SEMICOLON SEMICOLON RPAREN stmt
		{
			$$ = TreeNode::newStmtNode(ForK);
			$$->children[3] = $6;
		}
		;

input_stmt:	INPUT LPAREN id RPAREN SEMICOLON
			{
				$$ = TreeNode::newStmtNode(InputK);
				$$->children[0] = $3;
			}
			;

output_stmt:	OUTPUT LPAREN expr RPAREN SEMICOLON
				{
					$$ = TreeNode::newStmtNode(OutputK);
					$$->children[0] = $3;
				}
				;

%%

/////////////////////////////////////////////////////////////////////////////
// programs section

int main(void)
{
	int n = 1;
	mylexer lexer;
	myparser parser;
	freopen("a.txt","r",stdin);
	if(parser.yycreate(&lexer))
	{
		if(lexer.yycreate(&parser))
		{
			n = parser.yyparse();
		}
	}
	freopen("CON","r",stdin);
	string code_str;
	ofstream out("D:\\CODES\\x86\\compilers-homework2\\out.asm");
	if (out.is_open())   
    {  
		out.clear();
		out << code.str();
		out.close();  
    }
	cout<<endl<<endl;
	system("pause");
	return n;
}
