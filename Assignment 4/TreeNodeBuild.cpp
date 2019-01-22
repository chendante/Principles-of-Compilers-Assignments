#include "TreeNode.h"

TreeNode::TreeNode()
{
    this->num = node_num++;
    this->line = num_lines;
    for (int i = 0; i<MAXCHILDREN; i++)
    {
        this->children[i] = NULL;
    }
    this->sibling = NULL;
    this->nodekind = EMPTY;
}

//向兄弟链表的最后一位加个弟弟
void TreeNode::newBrother(TreeNode* bro)
{
    TreeNode *tmp = this;
    while(tmp->sibling != NULL)
    {
        tmp = tmp->sibling;
    }
    tmp->sibling = bro;
}

TreeNode* TreeNode::newStmtNode(StmtKind kind)
{
    TreeNode* t = new TreeNode();
    t->nodekind = StmtK;
    t->kind.stmt = kind;
    if(kind == IfK||kind == ForK||kind == WhileK)
    {
        t->label_true = label_num;
        label_num++;
        t->label_false = label_num;
        label_num++;
    }
    return t;
}

TreeNode* TreeNode::newExprNode(ExpKind kind)
{
    TreeNode* t = new TreeNode();
    t->nodekind = ExpK;
    t->kind.expr = kind;
    t->type = Void;
    return t;
}

TreeNode* TreeNode::newOpNode(int token)
{
    TreeNode* res = newExprNode(OpK);
    res->attr.op = token;
    return res;
}

// 单目运算符的语句
TreeNode* TreeNode::newSingleNode(int token,TreeNode* fr)
{
    TreeNode* res = newOpNode(token);
    res->children[0] = fr;
    res->tmp_var = tmp_var_num;
    tmp_var_num++;
    return res;
}

// 双目运算符的语句
TreeNode* TreeNode::newDoubleNode(int token,TreeNode* fr,TreeNode* sc)
{
    TreeNode* res = newOpNode(token);
    res->children[0] = fr;
    res->children[1] = sc;
    res->tmp_var = tmp_var_num;
    tmp_var_num++;
    return res;
}

// 字母节点
TreeNode* TreeNode::newLetterNode(string str)
{
    TreeNode* res = newExprNode(ConstK);
    res->attr.c_value = str[1];
    res->type = Char;
    return res;
}

// 数字节点
TreeNode* TreeNode::newIntNode(string str)
{
    TreeNode* res = newExprNode(ConstK);
    res->attr.val = stoi(str);
    res->type = Integer;
    return res;
}

// 变量节点
TreeNode* TreeNode::newIdNode(string str)
{
    TreeNode* res = newExprNode(IdK);
    res->type = Void;
    res->attr.name = (char*)(m_list.GetID(str)->name.data());
    return res;
}