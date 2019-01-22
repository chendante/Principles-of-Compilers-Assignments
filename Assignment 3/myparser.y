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
// 当节点类型为type时，才用到TypeK
typedef enum {StmtK,ExpK,TypeK} NodeKind;
typedef enum {IfK,WhileK,ForK,AssignK,ReadK,WriteK,DeclK,StmtsK} StmtKind;
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
			res->type = Void;
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
			res->type = Void;
			this->table[name] = res;
			return res;
		}

		bool IsPresence(char* c_name)
		{
			string name = c_name;
			if(table.find(name) != table.end())
			{
				return true;
			}
			else
			{
				return false;
			}
		}

		bool addType(char* c_name, ExpType type)
		{
			string name = c_name;
			Var* tmp;
			if(table.find(name) != table.end())
			{
				tmp = table.find(name)->second;
				if(tmp->type == Void)
				{
					tmp->type = type;
					return true;
				}
			}
			return false;
		}

		ExpType getType(char* c_name)
		{
			string name = c_name;
			Var* tmp;
			if(table.find(name) != table.end())
			{
				tmp = table.find(name)->second;
				return tmp->type;
			}
			return Void;
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

// ****************************************************************
	// 自此之下为用于后序遍历整棵树，打印节点信息所写函数
	// 展示每个节点
	void display()
	{
		for(int i=0;i<MAXCHILDREN;i++)
		{
			if(this->children[i] != NULL)
				this->children[i]->display();
		}
		this->printNode();
		if(this->sibling != NULL)
		{
			this->sibling->display();
		}
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
				cout<<"Integer\t";
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
// **********************************************************************
	//打印错误信息
	static void typecheckError(TreeNode* node,string error_info)
	{
		cout<<"error in node:"<<node->num<<" error info: "<<error_info<<endl;
	}

	static void typecheckError_line(TreeNode* node,string error_info)
	{
		cout<<"error in line:"<<node->line<<" error info: "<<error_info<<endl;
	}

	// 类型检查
	void typecheckStart()
	{
		for(int i=0;i<MAXCHILDREN;i++)
		{
			if(this->children[i] != NULL)
			{
				this->children[i]->typecheckStart();
			}
		}
		if(this->sibling != NULL)
		{
			this->sibling->typecheckStart();
		}
		this->typecheckNode();
	}

	void typecheckNode()
	{
		switch(this->nodekind)
		{
			case StmtK:
				this->typecheckStmt();
				break;
			case ExpK:
				this->typecheckExp();
				break;
			case TypeK:
				//this->typecheckType();
				break;
		}
	}

	void typecheckStmt()
	{
		switch(this->kind.stmt)
		{
			case IfK:
			{
				if(this->children[0] != NULL)
				{
					if(this->children[0]->type != Boolean)
					{
						typecheckError(this, "if check is not Boolean");
					}
				}
				break;
			}
			case WhileK:
			{
				if(this->children[0] != NULL)
				{
					if(this->children[0]->type != Boolean)
					{
						typecheckError(this, "while check is not Boolean");
					}
				}
				break;
			}
			case ForK:
			{
				if(this->children[1] != NULL)
				{
					if(this->children[0]->type != Boolean)
					{
						typecheckError(this, "for check is not Boolean");
					}
				}
			}
			case AssignK:
			{
				if(this->children[0]->type != this->children[1]->type)
				{
					typecheckError(this,"assign stmt type error");
				}
				else
				{
					this->type = this->children[0]->type;
				}
				break;
			}
			case ReadK:
				break;
			case WriteK:
				break;
			case DeclK:
			{
				// ExpType tmp_type = this->children[0]->type;
				// TreeNode* tmp_node = this->children[1];
				// while(tmp_node != NULL)
				// {
				// 	tmp_node->type = tmp_type;
				// 	tmp_node = tmp_node->sibling;
				// 	m_list.addType(tmp_node->attr.name, tmp_type);
				// }
				break;
			}
			case StmtsK:
				break;
		}
	}

	void typecheckExp()
	{
		switch(this->kind.expr)
		{
			case OpK:
				this->typecheckOp();
				break;
			case ConstK:
				break;
			case IdK:
				// 当遇见一个Id，如果该id节点没有类型，则说明该id节点不是在声明语句中的
				// 遇见这种情况，说明我们需要检查该节点之前出现过没有声明语句
				// 即在符号表中查看该节点是否已经addtype
				if( this->type == Void)
				{
					ExpType tmp_type = m_list.getType(this->attr.name);
					if( tmp_type == Void)
					{
						typecheckError(this,string(this->attr.name) + " didn't declare");
					}
					else
					{
						this->type = tmp_type;
					}
				}
				else
				{
					// 当该节点有类型，则为其在符号表中添加类型
					// 当没有成功时，说明之前已经有类型被赋予了
					if(!m_list.addType(this->attr.name,this->type))
					{
						typecheckError(this,string(this->attr.name) + " duplicate declare");
					}
				}
				break;
		}
	}

	void typecheckOp()
	{
		switch(this->attr.op)
		{
			case ADD:
			case SUB:
			case MUL:
			case DIV:
			case MOD:
			case USUB:
			case INC:
			case DEC:
			case M_LEFT:
			case M_RIGHT:
			case B_AND:
			case B_EOR:
			case B_IOR:
			case B_OPP:
				this->type = Integer;
				if(this->children[0]->type == Integer && 
				(this->children[1] == NULL || this->children[1]->type == Integer))
				{
					this->Calculate();
				}
				else
				{
					typecheckError(this,"expr op error");
				}
				break;
			case EQ:
			case GRT:
			case LET:
			case GRE:
			case LEE:
			case NE:
				this->type = Boolean;
				if(this->children[0]->type == Integer && 
				(this->children[1] == NULL || this->children[1]->type == Integer))
				{
					this->Calculate();
				}
				else
				{
					typecheckError(this,"expr op error");
				}
				break;
			case AND:
			case OR:
			case NOT:
				this->type = Boolean;
				if(this->children[0]->type == Boolean && 
				(this->children[1] == NULL || this->children[1]->type == Boolean))
				{
					this->Calculate();
				}
				else
				{
					typecheckError(this,"expr op error");
				}
				break;
		}
	}

	//调用这个函数之前已经经过了类型检查
	void Calculate()
	{
		// 检查是否所有节点都可以进行计算
		for(int i=0 ; i<MAXCHILDREN ;i++)
		{
			// 如果子节点中有节点不是固定值，则直接返回
			if(this->children[i] != NULL && this->children[i]->kind.expr != ConstK)
			{
				return;
			}
		}

		// 经过上面的检查，发现所有节点都是固定值节点，那么该节点也必然可以计算为固定值
		this->kind.expr = ConstK;
		switch(this->attr.op)
		{
			case ADD:
				this->attr.val = this->children[0]->attr.val + this->children[1]->attr.val;
				break;
			case SUB:
				this->attr.val = this->children[0]->attr.val - this->children[1]->attr.val;
				break;
			case MUL:
				this->attr.val = this->children[0]->attr.val * this->children[1]->attr.val;
				break;
			case DIV:
				this->attr.val = this->children[0]->attr.val / this->children[1]->attr.val;
				break;
			case MOD:
				this->attr.val = this->children[0]->attr.val % this->children[1]->attr.val;
				break;
			case USUB:
				this->attr.val = -(this->children[0]->attr.val);
				break;
			case INC:
				this->attr.val = this->children[0]->attr.val + 1;
				break;
			case DEC:
				this->attr.val = this->children[0]->attr.val - 1;
				break;
			case M_LEFT:
				this->attr.val = this->children[0]->attr.val << this->children[1]->attr.val;
				break;
			case M_RIGHT:
				this->attr.val = this->children[0]->attr.val >> this->children[1]->attr.val;
				break;
			case EQ:
				this->attr.val = this->children[0]->attr.val == this->children[1]->attr.val;
				break;
			case GRT:
				this->attr.val = this->children[0]->attr.val > this->children[1]->attr.val;
				break;
			case LET:
				this->attr.val = this->children[0]->attr.val < this->children[1]->attr.val;
				break;
			case GRE:
				this->attr.val = this->children[0]->attr.val >= this->children[1]->attr.val;
				break;
			case LEE:
				this->attr.val = this->children[0]->attr.val <= this->children[1]->attr.val;
				break;
			case NE:
				this->attr.val = this->children[0]->attr.val != this->children[1]->attr.val;
				break;
			case AND:
				this->attr.val = this->children[0]->attr.val && this->children[1]->attr.val;
				break;
			case OR:
				this->attr.val = this->children[0]->attr.val || this->children[1]->attr.val;
				break;
			case NOT:
				this->attr.val = !this->children[0]->attr.val;
				break;
			case B_AND:
				this->attr.val = this->children[0]->attr.val & this->children[1]->attr.val;
				break;
			case B_EOR:
				this->attr.val = this->children[0]->attr.val ^ this->children[1]->attr.val;
				break;
			case B_IOR:
				this->attr.val = this->children[0]->attr.val | this->children[1]->attr.val;
				break;
			case B_OPP:
				this->attr.val = ~this->children[0]->attr.val;
				break;
		}
		for(int i=0;i<MAXCHILDREN;i++)
		{
			this->children[i] = NULL;
		}
		cout<<"calculate : "<<" type: ";
		if( this->type == Boolean)
		{
			cout<<"Boolean";
		}
		else if(this->type == Integer)
		{
			cout<<"Integer";
		}
		cout<<"value: "<<this->attr.val<<endl;
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
			$$->typecheckStart();
			$$->display();
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
