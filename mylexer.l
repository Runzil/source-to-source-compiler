%{

  #include <math.h>
  #include <stdio.h>    
  #include <string.h>
  #include "myanalyzer.tab.h"
  #include "cgen.h"
  
  int line_num = 1;
%}


ID      [a-zA-Z][0-9a-zA-Z_]*

DIGIT   [0-9]
NUMBER  0|[1-9][0-9]*
DECIMAL ("."{NUMBER})|({NUMBER}("."{NUMBER}))
REAL    {DECIMAL}([eE][+-]?{NUMBER})?


STRING \"[^\n]*\"

SYMBOL  [-+*/:_$%!#@&~^()]

FRONT_ZERO_ERROR   [0]+({NUMBER}|{REAL})
CLOSE_STRING_ERROR  \"[^\n\"]*


%%


integer     { return KW_integer; }
scalar      {  return KW_scalar; }
str         {  return KW_str; }
boolean     {  return KW_boolean; }
True        {  return KW_True; }
False       {  return KW_False; }
const       {  return KW_const; }
if          {  return KW_if; }
else        {  return KW_else; }
endif       {  return KW_endif; }
for         {  return KW_for; }
in          {  return KW_inNUMBER; }
endfor      {  return KW_endfor; }
while       {  return KW_while; }
endwhile    { return KW_endwhile; }
break       {  return KW_break; }
continue    {  return KW_continue; }
not         {  return KW_not; }
and         {  return KW_and; }
or          {  return KW_or; }
def         { return KW_def; }
enddef      { return KW_enddef; }
main        { return KW_main; }
return      { return KW_return; }
comp        { return KW_comp; }
endcomp     { return KW_endcomp; }
of          { return KW_of; }

"+"         { return OP_Plus; }
"-"         { return OP_Minus; }
"*"         { return OP_Star; }
"/"         { return OP_Slash; }
"%"         { return OP_Percent; }
"**"        { return OP_DoubleStar; }

"=="        { return OP_DoubleEqual; }
"!="        { return OP_Exclequal; }
"<"         { return OP_Smaller; }
"<="        { return OP_SmallerEqual; }
">"         { return OP_Greater; }
">="        { return OP_GreaterEqual; }

"="         { return OP_Equal; }
"+="        { return OP_PlusEqual; }
"-="        { return OP_MinusEqual; }
"*="        { return OP_StarEqual; }
"/="        { return OP_SlashEqual; }
"%="        { return OP_PercentEqual; }
":="        { return OP_ColonEqual; }

"("         { return TK_LeftParenthesis; }
")"         { return TK_RightParenthesis; }
";"         { return TK_Semicolon; }
","         { return TK_Comma; }
"["         { return TK_LeftBracket; }
"]"         { return TK_RightBracket; }
":"         { return TK_Colon; }
"."         { return TK_Dot; }


{ID}        { yylval.str = strdup(yytext);  return TK_IDENT; }
{NUMBER}    { yylval.str = strdup(yytext);  return TK_INT; }
{REAL}      { yylval.str = strdup(yytext);  return TK_REAL; }
{STRING}    { yylval.str = strdup(yytext);  return TK_STRING; }

"--"[^\n]*  		printf("//Line %d: line comment: %s\n", line_num, yytext);/* eat line comments */



{FRONT_ZERO_ERROR} 	printf("Line %d: invalid 0 in front of number \n", line_num);
{CLOSE_STRING_ERROR}	printf("Line %d: Quote not closing String not identified \n", line_num);

[ \r\t]+	   /* eat whitespace */

.           { printf("Line %d Lexical Error: Unrecognized literal %s\n", line_num, yytext); }
\n 	    ++line_num;  

<<EOF>> 	return EOF;


%%
