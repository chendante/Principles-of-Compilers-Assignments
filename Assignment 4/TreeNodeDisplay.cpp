#include "TreeNode.h"

// 展示每个节点
void TreeNode::display()
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

void TreeNode::printNode()
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

void TreeNode::printType()
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

void TreeNode::printStmt()
{
    string stmt_list[] = {"If Stmt","While Stmt","For Stmt","Assign Stmt","Input Stmt","Output Stmt","Decl Stmt","Stmts"};
    cout<<stmt_list[this->kind.stmt]<<"\t\t\t";
}

void TreeNode::printExp()
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

void TreeNode::printOp()
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

void TreeNode::printId()
{
    cout<<string(this->attr.name)<<"\t\t";
}

void TreeNode::printConst()
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