%{
#include <stdio.h>
#include "cgen.h"


extern int yylex(void);

extern int line_num;
%}

%union {
	char* str;
}

%token KW_inNUMBER
%token KW_integer
%token KW_scalar
%token KW_str
%token KW_boolean
%token KW_True
%token KW_False
%token KW_const
%token KW_if
%token KW_else
%token KW_endif
%token KW_for
%token KW_in
%token KW_endfor
%token KW_while
%token KW_endwhile
%token KW_break
%token KW_continue
%token KW_not
%token KW_and
%token KW_or
%token KW_def
%token KW_enddef
%token KW_main
%token KW_return
%token KW_comp
%token KW_endcomp
%token KW_of

%token OP_Plus
%token OP_Minus
%token OP_Star
%token OP_Slash
%token OP_Percent
%token OP_DoubleStar
%token OP_DoubleEqual
%token OP_Exclequal
%token OP_Smaller
%token OP_SmallerEqual
%token OP_Greater
%token OP_GreaterEqual
%token OP_Equal
%token OP_PlusEqual
%token OP_MinusEqual
%token OP_StarEqual
%token OP_SlashEqual
%token OP_PercentEqual
%token OP_ColonEqual

%token TK_LeftParenthesis
%token TK_RightParenthesis
%token TK_Semicolon
%token TK_Comma
%token TK_LeftBracket
%token TK_RightBracket
%token TK_Colon
%token TK_Dot

%token <str> TK_IDENT
%token <str> TK_INT
%token <str> TK_REAL
%token <str> TK_STRING


%start input

%type <str>  start declx Declarations4 expression datatypes fbody Mainfunc decl3 args function numbers funcinformat funcin FuncReturn whileargval Funccall assign ifmodule Whilemodule formodule forargs2 forargsval malloc 

//PRIORITIES
%right OP_Equal OP_PlusEqual OP_MinusEqual OP_StarEqual OP_SlashEqual OP_PercentEqual OP_ColonEqual
%left KW_or 
%left KW_and
%right KW_not
%left OP_DoubleEqual OP_Exclequal
%left OP_Greater OP_GreaterEqual OP_Smaller OP_SmallerEqual
%left OP_Plus OP_Minus
%left OP_Star OP_Slash
%right TK_Dot TK_LeftParenthesis TK_RightParenthesis TK_LeftBracket TK_RightBracket
%right OP_DoubleStar


%%

input:
	%empty
	|start
	{
		if (yyerror_count == 0) {
			printf("//=================PROGRAM IN C=================\n");
			printf("#include <stdio.h>\n");
			puts(c_prologue);
			printf("%s\n", $1);	
		}
	}
	;

start:
	declx
	|function
	|start function  {$$ = template("%s%s",$1,$2);}
	;

declx:
       Declarations4
      | declx Declarations4 {$$ = template("%s%s",$1,$2);}
      
      

args:
	TK_LeftParenthesis {$$ = template("(");}
	|args OP_Minus   {$$ = template("%s -", $1);}
	|args OP_Slash   {$$ = template("%s / ", $1);}
	|args OP_Star {$$ = template("%s * ", $1);}
	|args OP_Plus {$$ = template("%s + ", $1);}
	|args OP_Percent {$$ = template("%s %% ", $1);}
	|args OP_DoubleStar whileargval {$$ = template("pow(%s, %s) ", $1,$3);}
	|args TK_Comma   {$$ = template("%s, ", $1);}
	|args KW_and   {$$ = template("%s && ", $1);}
	|args KW_or   {$$ = template("%s ||", $1);}
	|args TK_LeftParenthesis {$$ = template("%s ( ", $1);}
	|args TK_RightParenthesis {$$ = template("%s ) ", $1);} 
	|args TK_LeftBracket {$$ = template("%s [ ", $1);}
	|args TK_RightBracket {$$ = template("%s ] ", $1);}
	|args OP_SmallerEqual {$$ = template("%s <= ", $1);}
	|args OP_Smaller   {$$ = template("%s < ", $1);}
	|args OP_Greater {$$ = template("%s > ", $1);}
	|args OP_GreaterEqual {$$ = template("%s >= ", $1);}
	|args OP_Exclequal {$$ = template("%s != ", $1);}
	|args OP_DoubleEqual   {$$ = template("%s == ", $1);}
	|KW_True   {$$ = template("1");}
	|KW_False   {$$ = template("0");}
	|args whileargval {$$ = template("%s%s",$1,$2);}
	|args TK_STRING {$$ = template("%s%s",$1,$2);}
	|whileargval
	|TK_STRING
	|OP_Minus {$$ = template("-");}
	
	
	
fbody:
	%empty  {$$ = template("");}
	|Declarations4 fbody {$$ = template("%s%s",$1,$2);}
	|assign fbody {$$ = template("%s%s",$1,$2);}
	|FuncReturn fbody {$$ = template("%s%s",$1,$2);}
	|Funccall fbody {$$ = template("%s%s",$1,$2);}
	|ifmodule fbody {$$ = template("%s%s",$1,$2);}
	|Whilemodule fbody {$$ = template("%s%s",$1,$2);}
	|formodule fbody {$$ = template("%s%s",$1,$2);}
	|KW_continue TK_Semicolon fbody {$$ = template("continue; \n%s",$3);}
	|KW_break TK_Semicolon fbody {$$ = template("break; \n%s",$3);}
	|malloc fbody {$$ = template("%s%s",$1,$2);}



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////for expressions
Declarations4:
	KW_const TK_IDENT OP_Equal decl3 TK_Colon datatypes TK_Semicolon
	 {$$ = template("const %s %s = %s;\n",$6,$2,$4);} //for const multi integers
	|KW_const TK_IDENT OP_Equal TK_STRING TK_Colon datatypes TK_Semicolon
	 {$$ = template("const %s %s = %s;\n",$6,$2,$4);} //for strings
	|expression TK_Colon datatypes TK_Semicolon {$$ = template("%s %s;\n",$3,$1);} //a,b:integer;



	
assign:
	TK_IDENT OP_Equal args TK_Semicolon {$$ = template("%s = %s;\n",$1,$3);} //
	|TK_IDENT TK_LeftBracket TK_IDENT TK_RightBracket OP_Equal args TK_Semicolon {$$ = template("%s[%s] = %s;\n",$1,$3,$6);} //TODO GEN



Funccall:
	TK_IDENT TK_LeftParenthesis args TK_RightParenthesis TK_Semicolon  {$$ = template("%s(%s); \n",$1,$3);}  //writeInteger(a);

	
numbers:
	TK_INT
	|TK_REAL

	
decl3:
	numbers
	|OP_Minus numbers {$$ = template("-%s",$2);}
	;



expression:
	TK_IDENT
	|TK_IDENT TK_LeftBracket TK_INT TK_RightBracket {$$ = template("%s[%s]",$1,$3);}
	|expression TK_Comma TK_IDENT TK_LeftBracket TK_INT TK_RightBracket {$$ = template("%s,%s[%s]",$1,$3,$5);}
	|expression TK_Comma TK_IDENT {$$ = template("%s,%s",$1,$3);}
	;
	
		
datatypes:
	KW_integer {$$ = template("int");} 
	|KW_str  {$$ = template("char*");}
	|KW_boolean {$$ = template("int");}
	|KW_scalar {$$ = template("double");}
	;
	

malloc:
	TK_IDENT OP_ColonEqual TK_LeftBracket 				//malloc 
	 args KW_for TK_IDENT TK_Colon args 
	 TK_RightBracket TK_Colon datatypes TK_Semicolon
	 {$$ = template("%s *%s = (%s*)malloc(%s * sizeof(%s)); \nfor(%s %s = 0 ; %s<%s; ++i)\n{ %s[%s] = %s; };\n",
	 $11,$1,$11,$8,$11,$11,$6,$6,$8,$1,$6,$4);}


	|TK_IDENT OP_ColonEqual TK_LeftBracket 				//malloc 
	 args KW_for TK_IDENT TK_Colon KW_integer KW_inNUMBER TK_IDENT KW_of TK_INT 
	 TK_RightBracket TK_Colon datatypes TK_Semicolon
	 {$$ = template("%s *%s = (%s*)malloc(%s * sizeof(%s)); \nfor(int %s_i = 0 ; %s_i<%s; ++%s_i)\n{ %s %s = %s[%s_i]; \n%s[%s_i]= %s;}\n"
	 ,$15,$1,$15,$12,$15,$10,$10,$12,$10,$15,$6,$10,$10,$1,$10,$4);}
	
	

	

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////if function

ifmodule: 
	KW_if TK_LeftParenthesis args TK_RightParenthesis TK_Colon fbody KW_endif TK_Semicolon{$$ = template("if (%s) {\n\n%s}\n",$3,$6);}
	|KW_if TK_LeftParenthesis args TK_RightParenthesis TK_Colon fbody KW_else TK_Colon fbody KW_endif TK_Semicolon
	{$$ = template("if (%s) {\n\n%s} \nelse { \n%s}\n",$3,$6,$9);}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////for while functions
Whilemodule:	
	KW_while args TK_Colon fbody KW_endwhile TK_Semicolon{$$ = template("while %s {\n\n%s}\n",$2,$4);}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////for for functions
formodule:
	KW_for TK_IDENT KW_inNUMBER TK_LeftBracket TK_INT TK_Colon forargs2 TK_Colon TK_INT  TK_RightBracket TK_Colon fbody KW_endfor TK_Semicolon //for num in [3: limit+1: 2]: 
	{$$ = template("for(int %s=%s; %s<%s; %s+=%s) {\n%s}\n",$2,$5,$2,$7,$2,$9,$12);}
	|KW_for TK_IDENT KW_inNUMBER TK_LeftBracket TK_INT TK_Colon forargs2 TK_RightBracket TK_Colon fbody KW_endfor TK_Semicolon //for num in [0:50]:
	{$$ = template("for(int %s=%s; %s<%s; %s++) {\n%s}\n",$2,$5,$2,$7,$2,$10);}


forargs2:
	forargsval
	|forargsval OP_Star forargs2 {$$ = template("%s*%s",$1,$3);}
	|forargsval OP_Plus forargs2 {$$ = template("%s+%s",$1,$3);}
	|forargsval OP_Minus forargs2 {$$ = template("%s-%s",$1,$3);}
	|forargsval OP_Slash forargs2 {$$ = template("%s/%s",$1,$3);}
	|forargsval OP_Percent forargs2 {$$ = template("%s%%%s",$1,$3);}
	|forargsval OP_DoubleStar forargs2 {$$ = template("pow(%s, %s)",$1,$3);}

forargsval:
	TK_IDENT
	|TK_INT
	|TK_REAL
	;



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////for function
function:
	Mainfunc fbody KW_enddef TK_Semicolon {$$ = template("%s %s\n}\n\n",$1,$2);}
	|KW_def TK_IDENT TK_LeftParenthesis funcin TK_RightParenthesis OP_Minus OP_Greater datatypes TK_Colon fbody KW_enddef TK_Semicolon
	{$$ = template("%s %s(%s){\n\n%s\n}\n\n",$8,$2,$4,$10);}
	|KW_def TK_IDENT TK_LeftParenthesis TK_RightParenthesis OP_Minus OP_Greater datatypes TK_Colon fbody KW_enddef TK_Semicolon
	{$$ = template("%s %s(){\n\n%s\n}\n\n",$7,$2,$9);}
	|KW_def TK_IDENT TK_LeftParenthesis funcin TK_RightParenthesis TK_Colon fbody KW_enddef TK_Semicolon
	 {$$ = template("void %s(%s){\n\n%s\n}\n\n",$2,$4,$7);}
	|KW_def TK_IDENT TK_LeftParenthesis funcin TK_RightParenthesis OP_Minus OP_Greater TK_IDENT TK_Colon fbody KW_enddef TK_Semicolon
	{$$ = template("void %s(%s){\n\n %s\n}\n\n",$2,$4,$10);}


funcinformat:
	TK_IDENT TK_Colon TK_IDENT {$$ = template("%s %s",$3,$1);}
	|TK_IDENT TK_Colon datatypes {$$ = template("%s %s",$3,$1);}
	|TK_IDENT TK_LeftBracket TK_RightBracket TK_Colon datatypes {$$ = template(" %s *%s",$5,$1);}



funcin:
	funcinformat
	|funcinformat TK_Comma funcin {$$ = template("%s, %s",$1,$3);}
	
	

Mainfunc:
	KW_def KW_main TK_LeftParenthesis TK_RightParenthesis TK_Colon {$$ = template("int main() { \n");}
	

FuncReturn:
	KW_return args TK_Semicolon{$$ = template("return %s;\n",$2);}



whileargval:
	TK_IDENT
	|TK_INT
	|TK_REAL
	;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
%%
int main ()
{
   if ( yyparse() == 0 )
		printf("Accepted!\n");
	else
		printf("Rejected!\n");
}
