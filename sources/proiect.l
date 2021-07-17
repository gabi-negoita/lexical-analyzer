%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "proiect.tab.h"

void yyerror(char * err);
%}

IDENTIFIER [a-zA-Z]
STRING_VALUE \"([ a-zA-Z0-9]|\\\\|\\\"|\\[0-9][0-9][0-9]|\\[ntv])*\"
NUMERICAL_VALUE [0-9]+
CHARACTERS [-,#+()/*="^~><@]
INCREMENT "++"
DECREMENT "--"
EQUAL "=="
NOT_EQUAL "!="
GREATER_OR_EQUAL ">="
LESS_OR_EQUAL "<="
SPACES [ \t]+
NEW_LINE \n
OTHER_CHARACTERS .

%%
{IDENTIFIER} {
    // printf("ID:\t\t[%s]\n", yytext);
    yylval.id = * yytext;
    return ID;
}

{STRING_VALUE} {
    char str[255];
    int index = 0;
    memset(str, 0, sizeof(str));
    for (int i = 1; i < strlen(yytext) - 1; i++)
    {
		if (yytext[i] == 92)
		{	// 92: backslash
			if (i + 1 <= strlen(yytext) - 1)
			{
				if (yytext[i + 1] == 92 || yytext[i + 1] == 34)
				{	// 92: backslash, 34: double-quotes
					str[index++] = yytext[i + 1];
					i += 1;
				}
				else if (yytext[i + 1] == 110)
				{	// 110: n (character)
					str[index++] = (char)10; // 10: new line (character)
					i += 1;
				}
				else if (yytext[i + 1] == 118)
				{	// 118: v (character)
					str[index++] = (char)11; // 11: vertical tab (character)
					i += 1;
				}
				else if (yytext[i + 1] == 116)
				{	// 116: t (character)
					str[index++] = (char)9; // 9: horizontal tab (character)
					i += 1;
				}
			}
			if (i + 3 <= strlen(yytext) - 1)
			{
				if (yytext[i + 1] >= 48 && yytext[i + 1] <= 57)
				{
					if (yytext[i + 2] >= 48 && yytext[i + 1] <= 57)
					{
						if (yytext[i + 3] >= 48 && yytext[i + 1] <= 57)
						{
							char octalString[3];
							memset(octalString, 0, sizeof(octalString));
							octalString[0] = yytext[i + 1];
							octalString[1] = yytext[i + 2];
							octalString[2] = yytext[i + 3];

							int decimalNumber = 0;
							int j = 0;
							int octalNumber = atoi(octalString);
							while(octalNumber != 0)
							{
								int pow = 1;
								for (int k = 0; k < j; k++)
									pow = pow * 8;
								decimalNumber += (octalNumber%10) * pow;
								++j;
								octalNumber /= 10;
							}
							str[index++] = (char)decimalNumber;
							i += 3;
						}
					}	
				}
			}
		}
		else	
			str[index++] = yytext[i];
    }
    // printf("VALUE:\t\t[%s]\n", str);
    yylval.str = strdup(str);
    return VALUE;
}

{NUMERICAL_VALUE} {
    // printf("NUMBER:\t\t[%s]\n", yytext);
    yylval.number = atoi(yytext);
    return NUMBER;
}

{CHARACTERS} { 
    // if (yytext[0] != '\n') printf("CHARACTER:\t[%s]\n", yytext); 
    return * yytext;
}

{INCREMENT} { 
    return INCREMENT; 
}

{DECREMENT} { 
    return DECREMENT;
}

{EQUAL} { 
    return EQUAL;
}

{NOT_EQUAL} { 
    return NOT_EQUAL;
}

{GREATER_OR_EQUAL} { 
    return GREATER_OR_EQUAL;
}

{LESS_OR_EQUAL} { 
    return LESS_OR_EQUAL;
}

{SPACES} { 
    printf("");
}

{NEW_LINE} { 
    return ENDL;
}

{OTHER_CHARACTERS} { 
	char err[] = "unknown character \"";
	strcat(err, yytext);
	strcat(err, "\"");
	yyerror(err);
}
%%
