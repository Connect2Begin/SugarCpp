﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Antlr4.StringTemplate;

namespace SugarCpp.Compiler
{
    public abstract class Visitor
    {
        public abstract Template Visit(Root root);

        public abstract Template Visit(GlobalBlock block);
        public abstract Template Visit(GlobalAlloc global_alloc);
        public abstract Template Visit(GlobalTypeDef global_typedef);
        public abstract Template Visit(GlobalUsing global_using);

        public abstract Template Visit(AutoType type);
        public abstract Template Visit(DeclType type);
        public abstract Template Visit(IdentType type);
        public abstract Template Visit(StarType type);
        public abstract Template Visit(RefType type);
        public abstract Template Visit(TemplateType type);
        public abstract Template Visit(ArrayType type);
        public abstract Template Visit(FuncType type);

        public abstract Template Visit(Import import);

        public abstract Template Visit(Class class_def);
        public abstract Template Visit(Namespace namespace_def);
        public abstract Template Visit(Enum enum_def);
        public abstract Template Visit(FuncDef func_def);

        public abstract Template Visit(StmtBlock block);
        public abstract Template Visit(StmtDefer stmt_defer);
        public abstract Template Visit(StmtFinally stmt_finally);

        public abstract Template Visit(StmtIf stmt_if);
        public abstract Template Visit(StmtWhile stmt_while);
        public abstract Template Visit(StmtFor stmt_for);
        public abstract Template Visit(StmtForEach stmt_for_each);
        public abstract Template Visit(StmtTry stmt_try);
        public abstract Template Visit(StmtTypeDef stmt_typedef);
        public abstract Template Visit(StmtUsing stmt_using);
        public abstract Template Visit(StmtSwitch stmt_switch);
        public abstract Template Visit(StmtSwitchItem stmt_switch_item);
        public abstract Template Visit(StmtReturn stmt);

        public abstract Template Visit(StmtExpr stmt_expr);

        public abstract Template Visit(MatchTuple match);

        public abstract Template Visit(ExprBracket expr);
        public abstract Template Visit(ExprAssign expr);
        public abstract Template Visit(ExprLambda expr);
        public abstract Template Visit(ExprCurryLambda expr);
        public abstract Template Visit(ExprTuple expr);
        public abstract Template Visit(ExprBin expr);
        public abstract Template Visit(ExprPrefix expr);
        public abstract Template Visit(ExprSuffix expr);
        public abstract Template Visit(ExprAlloc expr);
        public abstract Template Visit(ExprCall expr);
        public abstract Template Visit(ExprNewType expr);
        public abstract Template Visit(ExprNewArray expr);
        public abstract Template Visit(ExprDict expr);
        public abstract Template Visit(ExprAccess expr);
        public abstract Template Visit(ExprCond expr);
        public abstract Template Visit(ExprConst expr);
        public abstract Template Visit(ExprCast expr);
        public abstract Template Visit(ExprList expr);
        public abstract Template Visit(ExprListGeneration expr);

        public abstract Template Visit(ExprInfix expr);

        public abstract Template Visit(ExprWhere expr);
        public abstract Template Visit(ExprMatch expr);

        public abstract Template Visit(ExprBlock expr);
    }
}
