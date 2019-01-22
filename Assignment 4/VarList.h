#pragma once
#include <string>
#include <vector>
#include <map>
using namespace std;

typedef enum{n_main,braced_stmt,stmts,stmt,decl_stmt,type,id,assign_stmt,expr,factor,n_num,letter,while_stmt,if_stmt,for_stmt} Nonterminal;
// 当节点类型为type时，才用到TypeK
typedef enum {StmtK,ExpK,TypeK,EMPTY} NodeKind;
typedef enum {IfK,WhileK,ForK,AssignK,InputK,OutputK,DeclK,StmtsK} StmtKind;
typedef enum {OpK,ConstK,IdK} ExpKind;
typedef enum {Void,Integer,Char,Boolean} ExpType;

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
		Var* GetID(string name);
		Var* GetID(char* c_name);
		bool IsPresence(char* c_name);
		bool addType(char* c_name, ExpType type);
		ExpType getType(char* c_name);
};