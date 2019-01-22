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
#include <fstream>
#include <iostream>
#include <string>
#include <vector>
#include <map>

#define MAXCHILDREN 5

using namespace std;
extern string token_text;
extern int num_lines;

int num_int = 0;
int num_char = 0;

typedef enum{n_main,braced_stmt,stmts,stmt,decl_stmt,type,id,assign_stmt,expr,factor,n_num,letter,while_stmt,if_stmt,for_stmt} Nonterminal;
typedef enum {StmtK,ExpK,TypeK} NodeKind;
typedef enum {IfK,WhileK,ForK,AssignK,ReadK,WriteK,DeclK,Stmts} StmtKind;
typedef enum {OpK,ConstK,IdK} ExpKind;
typedef enum {Void,Integer,Char,Boolean} ExpType;

int node_num = 0;

class Var
{
	public:
		string name;
		int num;	//某类型的第几个变量
		ExpType type;	//变量类型
		Var(){type = Void;}
};

//定义符号表
typedef map<string, Var*> VarTable;

class VarList
{
	public:
		VarTable table;
		
		VarList(){}
		Var* GetID(string name)
		{
			if(table.find(name) != table.end())
			{
				return table.find(name)->second;
			}
			Var* res = new Var();
			res->name = name;
			this->table[name] = res;
			return res;
		}

		Var* GetID(char* c_name)
		{
			string name = c_name;
			if(table.find(name) != table.end())
			{
				return table.find(name)->second;
			}
			Var* res = new Var();
			res->name = name;
			this->table[name] = res;
			return res;
		}
}m_list;

//定义一个节点
class TreeNode
{
public:
	int line;	// 第几行
	int num;	//节点编号
	union{int op; //操作符类型 token
		int val;	//int常数值
		char c_value; 
		char* name;	//ID名
		} attr;

	NodeKind nodekind;	//节点类型
	union{StmtKind stmt; ExpKind expr;} kind;
	TreeNode* children[MAXCHILDREN];	//子节点
	TreeNode* sibling;	//兄弟节点用到地方： stmts

	ExpType type;	//类型

	TreeNode()
	{
		this->num = node_num++;
		this->line = num_lines;
		for (int i = 0; i<MAXCHILDREN; i++)
		{
			this->children[i] = NULL;
		}
		this->sibling = NULL;
	}

	//向兄弟链表的最后一位加个弟弟
	void newBrother(TreeNode* bro)
	{
		TreeNode *tmp = this;
		while(tmp->sibling != NULL)
		{
			tmp = tmp->sibling;
		}
		tmp->sibling = bro;
	}

	static TreeNode* newStmtNode(StmtKind kind)
	{
		TreeNode* t = new TreeNode();
		t->nodekind = StmtK;
		t->kind.stmt = kind;
		return t;
	}

	static TreeNode* newExprNode(ExpKind kind)
	{
		TreeNode* t = new TreeNode();
		t->nodekind = ExpK;
		t->kind.expr = kind;
		t->type = Void;
		return t;
	}

	static TreeNode* newOpNode(int token)
	{
		TreeNode* res = newExprNode(OpK);
		res->attr.op = token;
		return res;
	}

	// 弹幕运算符的语句
	static TreeNode* newSingleNode(int token,TreeNode* fr)
	{
		TreeNode* res = newOpNode(token);
		res->children[0] = fr;
		return res;
	}

	// 双目运算符的语句
	static TreeNode* newDoubleNode(int token,TreeNode* fr,TreeNode* sc)
	{
		TreeNode* res = newOpNode(token);
		res->children[0] = fr;
		res->children[1] = sc;
		return res;
	}

	// 字母节点
	static TreeNode* newLetterNode(string str)
	{
		TreeNode* res = newExprNode(ConstK);
		res->attr.c_value = str[0];
		res->type = Char;
		return res;
	}

	// 数字节点
	static TreeNode* newIntNode(string str)
	{
		TreeNode* res = newExprNode(ConstK);
		res->attr.val = stoi(str);
		res->type = Integer;
		return res;
	}

	// 变量节点
	static TreeNode* newIdNode(string str)
	{
		TreeNode* res = newExprNode(IdK);
		res->type = Void;
		res->attr.name = (char*)(m_list.GetID(str)->name.data());
		return res;
	}

	// 展示每个节点
	void display()
	{
		for(int i=0;i<MAXCHILDREN;i++)
		{
			if(this->children[i] != NULL)
				this->children[i]->display();
		}
		if(this->sibling != NULL)
		{
			this->sibling->display();
		}
		this->printNode();
	}

	void printNode()
	{
		cout<<this->num<<":\t";
		switch(this->nodekind)
		{
			case StmtK:
				this->printStmt();
				break;
			case ExpK:
				this->printExp();
				break;
			case TypeK:
				this->printType();
				break;
		}
		cout<<"Children: ";
		for(int i=0;i<MAXCHILDREN;i++)
		{
			if(this->children[i] != NULL)
				cout<<" "<<this->children[i]->num;
		}
		if(this->sibling !=NULL)
		{
			cout<<" "<<this->sibling->num;
		}
		cout<<endl;
	}

	void printType()
	{
		cout<<"Type\t\t";
		switch(this->type)
		{
			case Integer:
				cout<<"Interger\t";
				break;
			case Char:
				cout<<"Char\t\t";
				break;
		}
	}

	void printStmt()
	{
		string stmt_list[] = {"If Stmt","While Stmt","For Stmt","Assign Stmt","Read Stmt","Write Stmt","Decl Stmt","Stmts"};
		cout<<stmt_list[this->kind.stmt]<<"\t\t\t";
	}

	void printExp()
	{
		switch(this->kind.expr)
		{
			case OpK:
				cout<<"Expr\t\t";
				this->printOp();
				break;
			case ConstK:
				this->printConst();
				break;
			case IdK:
				cout<<"ID\t\t";
				this->printId();
				break;
		}
	}

	void printOp()
	{
		switch(this->attr.op)
		{
			case ADD:
				cout<<"OP: +\t\t";
				break;
			case SUB:
				cout<<"OP: -\t\t";
				break;
			case MUL:
				cout<<"OP: *\t\t";
				break;
			case DIV:
				cout<<"OP: /\t\t";
				break;
			case MOD:
				cout<<"OP: %\t\t";
				break;
			case USUB:
				cout<<"OP: -\t\t";
				break;
			case INC:
				cout<<"OP: ++\t\t";
				break;
			case DEC:
				cout<<"OP: --\t\t";
				break;
			case M_LEFT:
				cout<<"OP: <<\t\t";
				break;
			case M_RIGHT:
				cout<<"OP: >>\t\t";
				break;
			case EQ:
				cout<<"OP: ==\t\t";
				break;
			case GRT:
				cout<<"OP: >\t\t";
				break;
			case LET:
				cout<<"OP: <\t\t";
				break;
			case GRE:
				cout<<"OP: >=\t\t";
				break;
			case LEE:
				cout<<"OP: <=\t\t";
				break;
			case NE:
				cout<<"OP: !=\t\t";
				break;
			case AND:
				cout<<"OP: &&\t\t";
				break;
			case OR:
				cout<<"OP: ||\t\t";
				break;
			case NOT:
				cout<<"OP: !\t\t";
				break;
			case B_AND:
				cout<<"OP: &\t\t";
				break;
			case B_EOR:
				cout<<"OP: ^\t\t";
				break;
			case B_IOR:
				cout<<"OP: |\t\t";
				break;
			case B_OPP:
				cout<<"OP: ~\t\t";
				break;
		}
	}

	void printId()
	{
		cout<<string(this->attr.name)<<"\t\t";
	}

	void printConst()
	{
		switch(this->type)
		{
			case Char:
				cout<<"Char\t\t";
				cout<<this->attr.c_value<<"\t\t";
				break;
			case Integer:
				cout<<"Integer\t\t";
				cout<<this->attr.val<<"\t\t";
				break;
		}
	}
}*root;

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

%token ASSIGN

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
		}
		;

//被{}括住的语句

braced_stmt:	LBRACE stmts RBRACE   
			{
				$$ = $2;
			}
			|	LBRACE	RBRACE
			{
				//$$ = NULL; 不能直接赋值NULL
				$$ = new TreeNode();
			}
			;

stmts:	stmt stmts
		{
			$$ = TreeNode::newStmtNode(Stmts);
			$$->children[0] = $1;
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
		;

decl_stmt: 	type idlist
			{
				$$ = TreeNode::newStmtNode(DeclK);
				$$->children[0] = $1;
				$$->children[1] = $2;
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
		|	assign_stmt	COMMA	idlist
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
		| B_AND expr
		{
			$$ = TreeNode::newSingleNode(B_AND,$2);
		}
		| B_EOR expr
		{
			$$ = TreeNode::newSingleNode(B_EOR,$2);
		}
		| B_IOR expr
		{
			$$ = TreeNode::newSingleNode(B_IOR,$2);
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
			$$->sibling = $9;
		}
			| FOR LPAREN expr SEMICOLON expr SEMICOLON RPAREN stmt
			{
				$$ = TreeNode::newStmtNode(ForK);
				$$->children[0] = $3;
				$$->children[1] = $5;
				$$->sibling = $8;
			}
			| FOR LPAREN expr SEMICOLON  SEMICOLON expr RPAREN stmt
			{
				$$ = TreeNode::newStmtNode(ForK);
				$$->children[0] = $3;
				$$->children[2] = $6;
				$$->sibling = $8;
			}
			| FOR LPAREN expr SEMICOLON SEMICOLON RPAREN stmt
			{
				$$ = TreeNode::newStmtNode(ForK);
				$$->children[0] = $3;
				$$->sibling = $7;
			}
			| FOR LPAREN SEMICOLON expr SEMICOLON expr RPAREN stmt
			{
				$$ = TreeNode::newStmtNode(ForK);
				$$->children[1] = $4;
				$$->children[2] = $6;
				$$->sibling = $8;
			}
			| FOR LPAREN SEMICOLON expr SEMICOLON RPAREN stmt
			{
				$$ = TreeNode::newStmtNode(ForK);
				$$->children[1] = $4;
				$$->sibling = $7;
			}
			| FOR LPAREN SEMICOLON  SEMICOLON expr RPAREN stmt
			{
				$$ = TreeNode::newStmtNode(ForK);
				$$->children[2] = $5;
				$$->sibling = $7;
			}
			| FOR LPAREN SEMICOLON SEMICOLON RPAREN stmt
			{
				$$ = TreeNode::newStmtNode(ForK);
				$$->sibling = $6;
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
	cout<<endl<<endl;
	system("pause");
	return n;
}
