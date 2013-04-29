grammar SugarCpp;

options
{
    output=AST;  
    ASTLabelType=CommonTree;  
    language=CSharp3;
	backtrack=true;
	memoize=true;
}

tokens
{
   INDENT;
   DEDENT;
   
   Root;
   Block;
   Import;
   Enum;
   Struct;
   Namespace;

   Func_Def;
   
   Stmt_Block;

   Stmt_Using;
   Stmt_Typedef;

   Stmt_If;
   Stmt_While;
   Stmt_For;
   Stmt_ForEach;

   Type_IDENT;
   Type_Ref;
   Type_Tuple;

   Func_Args;

   Expr_Alloc;

   Expr_Block;
   Expr_Cond;
   Expr_New_Type;
   Expr_New_Array;
   Expr_Bin;
   Expr_Return;
   
   Expr_Bin;
   Expr_Suffix;
   Expr_Prefix;

   Expr_Access;
   Expr_Dict;
   Expr_Call;
   Expr_Call_With;

   Expr_Infix;

   Expr_Lambda;

   Expr_Tuple;

   Ident_List;
   Match_Tuple;
}

@lexer::header
{
	using System;
	using System.Collections;
    using System.Collections.Generic;
	using System.Linq;
}

@lexer::members
{
	class Indentation
	{
		public int Level;
		public int CharIndex;

		public Indentation(int Level, int CharIndex)
		{
			this.Level = Level;
			this.CharIndex = CharIndex;
		}
	}

	int CurrentIndent = 0;
	Stack<Indentation> Indents = new Stack<Indentation>();
	Stack<int>[] Bracket = new Stack<int>[3];

	Queue<IToken> tokens = new Queue<IToken>();

    public override void Emit(IToken token) 
    {
        state.token = token;
        tokens.Enqueue(token);
    }

    public override IToken NextToken()
    {
        base.NextToken();
        if (tokens.Count == 0)
		{
			if (Indents.Count > 0)
			{
				Emit(new CommonToken(DEDENT, "DEDENT"));
				Indents.Pop();
				CurrentIndent = Indents.Count == 0 ? 0 : Indents.First().Level;
				base.NextToken();
				return tokens.Dequeue();
			}
            return new CommonToken(EOF, "EOF");
		}
        return tokens.Dequeue();
    }
} 

@lexer::init {
	CurrentIndent = 0;
	Bracket[0] = Stack<int>();
	Bracket[1] = Stack<int>();
	Bracket[2] = Stack<int>();
	Console.WriteLine("Init!");
}

@parser::header
{
	using System;
	using System.Collections;
    using System.Collections.Generic;
	using System.Linq;
}

@lexer  :: namespace { SugarCpp.Compiler }
@parser :: namespace { SugarCpp.Compiler }

public root
	: overall_block  NEWLINE* EOF
	;

overall_block
	: (NEWLINE* node)+
	;

node
	: func_def
	| import_def
	| enum_def
	| struct_def
	| namespace_def
	| stmt_alloc
	| stmt_using
	| stmt_typedef
	;

import_def
	: 'import' STRING? (INDENT (NEWLINE+ STRING)* NEWLINE* DEDENT)? -> ^(Import STRING*)
	;

enum_def
	: 'enum' IDENT '=' IDENT ('|' IDENT)* -> ^(Enum IDENT+)
	;

namespace_def
	: 'namespace' IDENT INDENT overall_block NEWLINE* DEDENT -> ^(Namespace IDENT overall_block)
	;

struct_def
	: 'struct' IDENT INDENT overall_block NEWLINE* DEDENT -> ^(Struct IDENT overall_block)
	;

type_name_op: '*' | '[' ']' | '&' ;
type_name
	: IDENT ('<' (type_name (',' type_name)*)? '>')? type_name_op* -> ^(Type_IDENT IDENT ('<' type_name* '>')?  type_name_op*)
	;

generic_parameter
	: '<' IDENT (','! IDENT)* '>'
	;

func_args
	: stmt_alloc (',' stmt_alloc)* -> ^(Func_Args stmt_alloc*)
	;

func_def
	: type_name IDENT generic_parameter? '(' func_args? ')' stmt_block
    ;

stmt_block
	: INDENT (NEWLINE+ stmt)* NEWLINE* DEDENT -> ^(Stmt_Block stmt*)
	;

stmt
	: stmt_expr
	;

stmt_expr
	: stmt_alloc
	| stmt_return
	| stmt_using
	| stmt_typedef
	| stmt_if
	| stmt_while
	| stmt_for
	| stmt_modify
	;

stmt_typedef
	: 'typedef' IDENT '=' type_name -> ^(Stmt_Typedef type_name IDENT)
	;

stmt_using_item: IDENT | 'namespace';
stmt_using
	: 'using' stmt_using_item* -> ^(Stmt_Using stmt_using_item*)
	;

stmt_return
	: 'return' expr? -> ^(Expr_Return expr?)
	;

stmt_if
	: 'if' '(' expr ')' stmt_block ('else' stmt_block)? -> ^(Stmt_If expr stmt_block stmt_block?)
	;

stmt_while
	: 'while' '(' expr ')' stmt_block -> ^(Stmt_While expr stmt_block)
	;

stmt_for
@init
{
	int type = 0;
}
	: 'for' '(' expr (';' expr ';' expr {type=0;} | 'in' expr {type=1;}) ')' stmt_block
	  -> {type==0}? ^(Stmt_For expr expr expr stmt_block)
	  -> ^(Stmt_ForEach expr expr stmt_block)
	;

ident_list
	: IDENT (',' IDENT)* -> ^(Ident_List IDENT+)
	;

stmt_alloc
	: ident_list ':' type_name ('=' expr)? -> ^(Expr_Alloc type_name ident_list expr?)
	;

stmt_modify
	: lvalue (modify_expr_op^ cond_expr)?
	;

expr
	: lambda_expr
	;

lambda_expr
	: '(' func_args ')' '=>' modify_expr -> ^(Expr_Lambda func_args modify_expr)
	| modify_expr
	;

modify_expr_op: ':=' | '=' | '+=' | '-=' | '*=' | '/=' | '%=' | '&=' | '^=' | '|=' | '<<=' | '>>=' ;
modify_expr
	: cond_expr (modify_expr_op^ modify_expr)?
	;

cond_expr_item: cond_expr ;
cond_expr
	: (a=or_expr -> $a) ('if' a=cond_expr_item 'else' b=cond_expr_item -> ^(Expr_Cond $a $cond_expr $b))?
	;

or_expr
	: (a=and_expr -> $a) ('||' b=and_expr -> ^(Expr_Bin '||' $or_expr $b))*
	;

and_expr
	: (a=bit_or -> $a) ('&&' b=bit_or -> ^(Expr_Bin '&&' $and_expr $b))*
	;

bit_or
	: (a=bit_xor -> $a) ('|' b=bit_xor -> ^(Expr_Bin '|' $bit_or $b))*
	;

bit_xor
	: (a=bit_and -> $a) ('^' b=bit_and -> ^(Expr_Bin '^' $bit_xor $b))*
	;

bit_and
	: (a=cmp_equ_expr -> $a) ('&' b=cmp_equ_expr -> ^(Expr_Bin '&' $bit_and $b))*
	;

cmp_equ_expr_op: '==' | '!=' ;
cmp_equ_expr
	: (a=cmp_expr -> $a) (cmp_equ_expr_op b=cmp_expr -> ^(Expr_Bin cmp_equ_expr_op $cmp_equ_expr $b))?
	;
	
cmp_expr_op: '<' | '<=' | '>' | '>=' ;
cmp_expr
	: (a=shift_expr -> $a) (cmp_expr_op b=shift_expr -> ^(Expr_Bin cmp_expr_op $cmp_expr $b))?
	;

shift_expr_op: '<<' | '>>' ;
shift_expr
	: (a=add_expr -> $a) (shift_expr_op b=add_expr -> ^(Expr_Bin shift_expr_op $shift_expr $b))*
	;

add_expr
	: (a=infix_expr -> $a) ( '+' b=infix_expr -> ^(Expr_Bin '+' $add_expr $b)
						   | '-' b=infix_expr -> ^(Expr_Bin '-' $add_expr $b)
						   )*
	;

infix_expr
	: (a=mul_expr -> $a) ( Infix_Func b=mul_expr  -> ^(Expr_Infix Infix_Func $infix_expr $b) )*
	;

mul_expr
	: (a=selector_expr -> $a) ( '*' b=selector_expr -> ^(Expr_Bin '*' $mul_expr $b)
						      | '/' b=selector_expr -> ^(Expr_Bin '/' $mul_expr $b)
						      | '%' b=selector_expr -> ^(Expr_Bin '%' $mul_expr $b)
						      )*
	;

selector_expr
	: (a=prefix_expr -> $a) ( '->*' b=IDENT -> ^(Expr_Access '->*' $selector_expr $b)
						    | '.*'  b=IDENT -> ^(Expr_Access '.*'  $selector_expr $b)
						    )*
	;

prefix_expr_op: '!' | '~' | '++' | '--' | '-' | '+' | '*' | '&' ;
prefix_expr
	: (prefix_expr_op prefix_expr) -> ^(Expr_Prefix prefix_expr_op prefix_expr)
	| 'new' type_name ( '(' expr_list? ')' -> ^(Expr_New_Type type_name expr_list?)
					  | '[' expr_list ']' -> ^(Expr_New_Array type_name expr_list))
	| suffix_expr
	;
	
expr_list
	: expr (','! expr)*
	;

suffix_expr
	: (a=atom_expr -> $a) ( '++' -> ^(Expr_Suffix '++' $suffix_expr)
					      | '--' -> ^(Expr_Suffix '--' $suffix_expr)
						  | '.' IDENT -> ^(Expr_Access '.' $suffix_expr IDENT)
						  | '->' IDENT -> ^(Expr_Access '->' $suffix_expr IDENT)
						  | '::' IDENT -> ^(Expr_Access '::' $suffix_expr IDENT)
						  | generic_parameter? '(' expr_list? ')' -> ^(Expr_Call $suffix_expr generic_parameter? expr_list?)
						  | '[' expr_list? ']' -> ^(Expr_Dict $suffix_expr expr_list?)
						  | ':' IDENT '(' expr_list? ')' -> ^(Expr_Call_With $suffix_expr IDENT expr_list?)
					      )*
	;

atom_expr
@init
{
	bool more_than_one = false;
}
	: NUMBER
	| IDENT
	| STRING
	| '(' expr (',' expr { more_than_one = true; } )* ')'
	 -> { more_than_one }? ^(Expr_Tuple expr+)
	 -> expr
	;

lvalue
	: (a=lvalue_atom -> $a) ( '++' -> ^(Expr_Suffix '++' $lvalue)
					        | '--' -> ^(Expr_Suffix '--' $lvalue)
						    | '.' IDENT -> ^(Expr_Access '.' $lvalue IDENT)
						    | '->' IDENT -> ^(Expr_Access '->' $lvalue IDENT)
						    | '::' IDENT -> ^(Expr_Access '::' $lvalue IDENT)
						    | generic_parameter? '(' expr_list? ')' -> ^(Expr_Call $lvalue generic_parameter? expr_list?)
						    | '[' expr ']' -> ^(Expr_Dict $lvalue expr)
					        )*
	;

lvalue_atom
	: '(' (lvalue (',' lvalue)*)? ')' -> ^(Match_Tuple lvalue*)
	| IDENT
	;

// Lexer Rules

IDENT: ('a'..'z' | 'A'..'Z' | '_')+ ('0'..'9')* ('::' ('a'..'z' | 'A'..'Z' | '_')+ ('0'..'9')*)*;

NUMBER: '0'..'9'+ ('.' '0'..'9'+)? ('ll' | 'f')?;

Infix_Func: '`' ('a'..'z' | 'A'..'Z' | '_')+ ('0'..'9')* ('::' ('a'..'z' | 'A'..'Z' | '_')+ ('0'..'9')*)* '`';

STRING
	: '"' (~'"')* '"'
	;

fragment
EXPONENT :
    ('e'|'E') ('+'|'-')? ('0'..'9')+
    ;


Left_Bracket
	: '(' | '[' | '{'
	{
		int k = $text == "(" ? 0 : $text == "[" ? 1 : 2;
		if (Bracket[k] == null) Bracket[k] = new Stack<int>();
		Bracket[k].Push(CharIndex);
	}
	;

Right_Bracket
	: ')' | ']' | '}'
	{
		int k = $text == "(" ? 0 : $text == "[" ? 1 : 2;
		int pos = Bracket[k].Pop();
		while (Indents.Count > 0 && pos < Indents.First().CharIndex)
		{
			Emit(new CommonToken(DEDENT, "DEDENT"));
			Indents.Pop();
			CurrentIndent = Indents.Count == 0 ? 0 : Indents.First().Level;
		}
	}
	;

NEWLINE
	: ('r'? '\n')+ SP?
	{
		int indent = $SP.text == null ? 0 : $SP.text.Length;
		if (indent > CurrentIndent)
		{
			Emit(new CommonToken(INDENT, "INDENT"));
			Emit(new CommonToken(NEWLINE, "NEWLINE"));
			Indents.Push(new Indentation(indent, CharIndex));
			CurrentIndent = indent;
		}
		else if (indent < CurrentIndent)
		{
			while (Indents.Count > 0 && indent < CurrentIndent)
			{
				Emit(new CommonToken(DEDENT, "DEDENT"));
				Indents.Pop();
				CurrentIndent = Indents.Count == 0 ? 0 : Indents.First().Level;
			}
			Emit(new CommonToken(NEWLINE, "NEWLINE"));
		}
		else
		{
			Emit(new CommonToken(NEWLINE, "NEWLINE"));
			Skip();
		}
	}
	;

fragment SP: ' '+ ;

INDENT: {0==1}?=> ('\n') ;
DEDENT: {0==1}?=> ('\n') ;