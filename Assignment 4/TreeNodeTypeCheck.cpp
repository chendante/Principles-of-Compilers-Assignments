#include "TreeNode.h"

void TreeNode::typecheckError(TreeNode* node,string error_info)
{
    cout<<"error in node:"<<node->num<<" error info: "<<error_info<<endl;
}

void TreeNode::typecheckError_line(TreeNode* node,string error_info)
{
    cout<<"error in line:"<<node->line<<" error info: "<<error_info<<endl;
}

// 类型检查
void TreeNode::typecheckStart()
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

void TreeNode::typecheckNode()
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

void TreeNode::typecheckStmt()
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
        case InputK:
            break;
        case OutputK:
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

void TreeNode::typecheckExp()
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

void TreeNode::typecheckOp()
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
void TreeNode::Calculate()
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