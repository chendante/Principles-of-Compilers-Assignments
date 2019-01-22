#pragma once
#include "VarList.h"
#include <iostream>
#include "myparser.h"
#include <sstream>
#define MAXCHILDREN 5
using namespace std;

extern VarList m_list;
extern int num_lines;
extern int node_num;
extern stringstream code;
extern int tmp_var_num;
extern int label_num;

class TreeNode
{
public:
	int line;	// 第几行
	int num;	//节点编号
	int tmp_var;	// 临时变量
	int label_true;
	int label_false;
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

	TreeNode();

	//向兄弟链表的最后一位加个弟弟
	void newBrother(TreeNode* bro);

	static TreeNode* newStmtNode(StmtKind kind);

	static TreeNode* newExprNode(ExpKind kind);

	static TreeNode* newOpNode(int token);

	// 单目运算符的语句
	static TreeNode* newSingleNode(int token,TreeNode* fr);

	// 双目运算符的语句
	static TreeNode* newDoubleNode(int token,TreeNode* fr,TreeNode* sc);

	// 字母节点
	static TreeNode* newLetterNode(string str);

	// 数字节点
	static TreeNode* newIntNode(string str);

	// 变量节点
	static TreeNode* newIdNode(string str);

// ****************************************************************
	// 自此之下为用于后序遍历整棵树，打印节点信息所写函数
	// 展示每个节点
	void display();

	void printNode();

	void printType();

	void printStmt();

	void printExp();

	void printOp();

	void printId();

	void printConst();

// **********************************************************************
	//打印错误信息
	static void typecheckError(TreeNode* node,string error_info);

	static void typecheckError_line(TreeNode* node,string error_info);

	// 类型检查
	void typecheckStart();

	void typecheckNode();

	void typecheckStmt();

	void typecheckExp();

	void typecheckOp();

	//调用这个函数之前已经经过了类型检查
	void Calculate();

// **********************************************************************
	// 以下为生成汇编代码
	static void genHeader();
	static void genDecl();
	void genMain();
	void genCode();
	void genExpr();
	void genOp();
	void genStmt();
	// void genCode();
	string genValue();
	string genLabelTrue();
	string genLabelFalse();
};