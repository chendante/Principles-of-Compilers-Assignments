#include "TreeNode.h"

void TreeNode::genHeader()
{
    code<<"\t.586\n"<<endl;
	code<<"\t.model flat, stdcall"<<endl;
	code<<"\toption casemap :none"<<endl;
	code<<endl;
	code<<"\tinclude \\masm32\\include\\windows.inc"<<endl;
	code<<"\tinclude \\masm32\\include\\user32.inc"<<endl;
	code<<"\tinclude \\masm32\\include\\kernel32.inc"<<endl;
	code<<"\tinclude \\masm32\\include\\masm32.inc"<<endl;
	code<<"\tinclude \\masm32\\include\\msvcrt.inc"<<endl;
	code<<endl;
	code<<"\tincludelib \\masm32\\lib\\user32.lib"<<endl;
	code<<"\tincludelib \\masm32\\lib\\kernel32.lib"<<endl;
	code<<"\tincludelib \\masm32\\lib\\masm32.lib"<<endl;
	code<<"\tincludelib \\masm32\\lib\\msvcrt.lib"<<endl;
	code<<"\tinclude \\masm32\\macros\\macros.asm"<<endl;
}

void TreeNode::genMain()
{
	genHeader();
	genDecl();
	code<<endl<<endl<<"\t.code"<<endl;
	code<<"_start:"<<endl;
	this->children[0]->genCode();
	code<<"\tinvoke ExitProcess, 0"<<endl;
	code<<"end _start"<<endl;
}

void TreeNode::genCode()
{
	switch(this->nodekind)
	{
		case StmtK:
			this->genStmt();
			break;
		case ExpK:
			this->genExpr();
			break;
		case TypeK:
			break;
	}
	if(sibling != NULL)
	{
		sibling->genCode();
	}
}

void TreeNode::genDecl()
{
	code<<"\n\n\t.data"<<endl;
	VarTable::iterator it;
	it = m_list.table.begin();
	while(it != m_list.table.end())
	{
		switch(it->second->type)
		{
			case Integer:
			{
				code<<"\t\t_"<<it->first<<" DWORD 0"<<endl;
				break;
			}
			case Char:
			{
				code<<"\t\t_"<<it->first<<" DWORD 0"<<endl;
				break;
			}
		}
		it++;
	}
	for(int i=0;i<tmp_var_num;i++)
	{
		code<<"\t\tt"<<i<<" DWORD ?"<<endl;
	}
	// code<<"\t\tintFormat db '%%d',0"<<endl;
	// code<<"\t\tcharFormat db '%%c',0"<<endl;
}

string TreeNode::genValue()
{
	string res;
	int r;
	switch(this->kind.expr)
	{
		case IdK:
			res = "_"+string(attr.name);
			break;
		case ConstK:
			switch(type)
			{
				case Char:
					r = attr.c_value;
					cout << attr.c_value;
					res = to_string(r);
					break;
				default:
					res = to_string(attr.val);
					break;
			}
			break;
		case OpK:
			res = "t"+to_string(this->tmp_var);
			break;
		case AssignK:
			return children[0]->genValue();
	}
	return res;
}

void TreeNode::genExpr()
{
	switch(this->kind.expr)
	{
		case OpK:
			this->genOp();
			break;
		case IdK:
			break;
		case ConstK:
			break;
	}

}

void TreeNode::genOp()
{
	TreeNode* child1 = this->children[0];
	TreeNode* child2 = this->children[1];
	child1->genCode();
	if(child2 != NULL)
	{
		child2->genCode();
	}
	code << "\tMOV eax,"<<child1->genValue()<<endl;
	switch(this->attr.op)
	{
		case ADD:
			code << "\tADD eax,"<<child2->genValue()<<endl;
			break;
		case SUB:
			code << "\tSUB eax,"<<child2->genValue()<< endl;
			break;
		case MUL:
			code << "\tIMUL eax, "<<child2->genValue()<< endl;
			break;
		case DIV:
			code<<"\tMOV edx, 0"<<endl;
			code<<"CDQ"<<endl;
			code<<"\tMOV ecx, "<<child2->genValue()<<endl;
			code<<"\tIDIV ecx"<<endl;
			break;
		case MOD:
			code << "\tMOV edx, 0" << endl;
			code<<"CDQ"<<endl;
			code<<"\tMOV ecx,"<<child2->genValue()<<endl;
			code<<"\tIDIV ecx"<<endl;
			code<<"\tMOV eax, edx"<<endl;
			break;
		case INC:
			code<<"\tINC eax"<<endl;
			if(child1->kind.expr == IdK)
			{
				code<<"\tMOV "<<child1->genValue()<<",eax"<<endl;
			}
			break;
		case DEC:
			code<<"\tDEC eax"<<endl;
			if(child1->kind.expr == IdK)
			{
				code<<"\tMOV "<<child1->genValue()<<",eax"<<endl;
			}
			break;
		case B_AND:
			code<<"\tAND eax,"<<child2->genValue()<<endl;
			break;
		case B_IOR:
			code<<"\tOR eax,"<<child2->genValue()<<endl;
			break;
		case B_EOR:
			code<<"\tXOR eax,"<<child2->genValue()<<endl;
			break;
		case B_OPP:
			code<<"\tNOT eax"<<endl;
			break;
		case M_LEFT:
			code<<"\tMOV ecx,"<<child2->genValue()<<endl;
			code<<"\tSHL eax, cl"<<endl;
			break;
		case M_RIGHT:
			code<<"\tMOV ecx, "<<child2->genValue()<<endl;
			code<<"\tSHR eax, cl"<<endl;
			break;
		case EQ:
			code<<"\tCMP eax,"<<child2->genValue()<<endl;
			code<<"\tsete al"<<endl;
			code<<"\tmovsx eax,al"<<endl;
			break;
		case GRT:
			code<<"\tCMP eax,"<<child2->genValue()<<endl;
			code<<"\tsetg al"<<endl;
			code<<"\tmovsx eax,al"<<endl;
			break;
		case LET:
			code<<"\tCMP eax,"<<child2->genValue()<<endl;
			code<<"\tsetl al"<<endl;
			code<<"\tmovsx eax,al"<<endl;
			break;
		case GRE:
			code<<"\tCMP eax,"<<child2->genValue()<<endl;
			code<<"\tsetge al"<<endl;
			code<<"\tmovsx eax,al"<<endl;
			break;
		case LEE:
			code<<"\tCMP eax,"<<child2->genValue()<<endl;
			code<<"\tsetle al"<<endl;
			code<<"\tmovsx eax,al"<<endl;
			break;
		case NE:
			code<<"\tCMP eax,"<<child2->genValue()<<endl;
			code<<"\tsetne al"<<endl;
			code<<"\tmovsx eax,al"<<endl;
			break;
		case AND:
			code<<"\tCMP "<<child2->genValue()<<", 0"<<endl;	//	cmp	DWORD PTR [rbp-12], 0
			code<<"\tje @L"<<this->num<<"2"<<endl;				//	je	@L2
			code<<"\tCMP "<<child1->genValue()<<", 0"<<endl;	//	cmp	DWORD PTR [rbp-8], 0
			code<<"\tje @L"<<this->num<<"2"<<endl;				//	je	@L2
			code<<"\tMOV eax, 1"<<endl;							//	mov	eax, 1
			code<<"\tjmp @L"<<this->num<<"3"<<endl;				//	jmp	@L3
			code<<"@L"<<this->num<<"2"<<endl;					//@L2:
			code<<"MOV eax, 0"<<endl;							//	mov	eax, 0
			code<<"@L"<<this->num<<"3"<<endl;					//@L3:
			break;
		case OR:
			code<<"\tCMP "<<child2->genValue()<<", 0"<<endl;	//	cmp	DWORD PTR [rbp-12], 0
			code<<"\tjne @L"<<this->num<<"2"<<endl;				//	jne	@L2
			code<<"\tCMP "<<child1->genValue()<<", 0"<<endl;	//	cmp	DWORD PTR [rbp-8], 0
			code<<"\tje @L"<<this->num<<"3"<<endl;				//	je	@L3
			code<<"@L"<<this->num<<"2"<<endl;					//@L2:
			code<<"\tMOV eax, 1"<<endl;							//	mov	eax, 1
			code<<"\tjmp @L"<<this->num<<"4"<<endl;				//	jmp	@L4
			code<<"@L"<<this->num<<"3"<<endl;					//@L3:
			code<<"MOV eax, 0"<<endl;							//	mov	eax, 0
			code<<"@L"<<this->num<<"4"<<endl;					//@L4:
			break;
		case NOT:
			code<<"\tCMP eax, 0"<<endl;
			code<<"\tsete al"<<endl;
			code<<"\tmovsx eax, al"<<endl;
			break;
	}
	code << "\tMOV "<<this->genValue()<< ", eax" << endl;
}

string TreeNode::genLabelTrue()
{
	string res;
	res = "@label_"+to_string(this->label_true);
	return res;
}

string TreeNode::genLabelFalse()
{
	string res;
	res = "@label_"+to_string(this->label_false);
	return res;
}

void TreeNode::genStmt()
{
	TreeNode* child1 = this->children[0];
	TreeNode* child2 = this->children[1];
	TreeNode* child3 = this->children[2];
	TreeNode* child4 = this->children[3];
	TreeNode* child5 = this->children[4];
	switch(this->kind.stmt)
	{
		case IfK:
			child1->genCode();
			code<<"\tcmp "<<child1->genValue()<<", 0"<<endl;
			code<<"\tje "<<this->genLabelTrue()<<endl;
			child2->genCode();
			code<<this->genLabelTrue()<<":"<<endl;
			break;
		case WhileK:
			code<<"\tjmp @label_"<<this->label_true<<endl;
			code<<this->genLabelFalse()<<":"<<endl;
			child2->genCode();
			code<<this->genLabelTrue()<<":"<<endl;
			child1->genCode();
			code<<"\tcmp "<<child1->genValue()<<", 0"<<endl;
			code<<"\tjne "<<this->genLabelFalse()<<endl;
			break;
		case ForK:
			if(child1 != NULL)
			{
				child1->genCode();
			}
			code<<"\tjmp "<<this->genLabelTrue()<<endl;
			code<<this->genLabelFalse()<<":"<<endl;
			if(child4 != NULL)
			{
				child4->genCode();
			}
			if(child3 != NULL)
			{
				child3->genCode();
			}
			code<<this->genLabelTrue()<<":"<<endl;
			if(child2 != NULL)
			{
				child2->genCode();
			}
			else{
				typecheckError_line(this," for error child2 is NULL");
			}
			code<<"\tcmp "<<child2->genValue()<<", 0"<<endl;
			code<<"\tjne "<<this->genLabelFalse()<<endl;
			break;
		case AssignK:
			if(child1->kind.expr != IdK)
			{
				typecheckError_line(child1,"right of assign should be id");
				return;
			}
			child2->genCode();
			code<<"\tMOV eax, "<<child2->genValue()<<endl;
			code<<"\tMOV "<<child1->genValue()<<", eax"<<endl;
			break;
		case InputK:
		{
			if(child1->type == Char)
			{
				code<<"\tinvoke crt_scanf, SADD(\"%c\",0), addr "<<child1->genValue()<<endl;
			}
			else if(child1->type == Integer)
			{
				code<<"\tinvoke crt_scanf, SADD(\"%d\",0), addr "<<child1->genValue()<<endl;
			}
			break;
		}
		case OutputK:
		{
			code<<"\tMOV eax,"<<child1->genValue()<<endl;
			if(child1->type == Char)
			{
				code<<"\tinvoke crt_printf, SADD(\"%c\",0), eax"<<endl;
			}
			else
			{
				code<<"\tinvoke crt_printf, SADD(\"%d\",0), eax"<<endl;
			}
			code<<"\tinvoke crt_printf,SADD(13,10)"<<endl;
			break;
		}
		case DeclK:
			child2->genCode();
			break;
		case StmtsK:
			child1->genCode();
			break;
	}
}