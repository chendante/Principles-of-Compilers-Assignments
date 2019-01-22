#include "VarList.h"

Var* VarList::GetID(string name)
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

Var* VarList::GetID(char* c_name)
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

bool VarList::IsPresence(char* c_name)
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

bool VarList::addType(char* c_name, ExpType type)
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

ExpType VarList::getType(char* c_name)
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