%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

void yyerror(char *);

extern FILE * yyin;
extern FILE * yyout;

char * sym[52];
%}

%union {
    char id;
    char * str;
    int number;
}

%token <id> ID 
%token <str> VALUE
%token <number> NUMBER
%token INCREMENT DECREMENT EQUAL NOT_EQUAL GREATER_OR_EQUAL LESS_OR_EQUAL ENDL

%type <str> statement
%type <str> id
%type <str> assignment

%right EQUALS NOT_EQUAL '>' GREATER_OR_EQUAL '<' LESS_OR_EQUAL
%left '+' '-'
%left '*' '/' '#'
%right INCREMENT DECREMENT '~' '^'
%nonassoc '(' ')'

%%
program:
  ENDL {
    printf("> ");
    }
| program ENDL {
    printf("> ");
    }
| statement ENDL {
	fprintf(yyout, "\'%s\'\n", $1);  
	printf("> ");
    }
| program statement ENDL { 
	fprintf(yyout, "\'%s\'\n", $2); 
	printf("> ");
    }
| assignment ENDL {
	printf("> ");
    }
| program assignment ENDL {
	printf("> ");
    }
;

assignment:
  ID '=' statement {        
	sym[$1] = $3;
        $$ = $3;
    }
| assignment ',' assignment
;

statement:
  id {
	if ($1 == NULL)
	    yyerror("undefined identifier");
	else
	    $$ = $1;
    }
| '(' statement ')' {
	$$ = $2; 
    }
| INCREMENT statement {
	$2[0] = $2[0] + 1;
	$$ = $2;
    }
| statement INCREMENT {
	$1[strlen($1) - 1] = $1[strlen($1) - 1] + 1;
	$$ = $1;
    }
| DECREMENT statement {
        $2[0] = $2[0] - 1;
        $$ = $2;
    }
| statement DECREMENT {
        $1[strlen($1) - 1] = $1[strlen($1) - 1] - 1;
        $$ = $1;
    }
| '^' statement {
	for (int i = 0; i < strlen($2); i++)
	    if ($2[i] >= 'a' && $2[i] <= 'z')
		$2[i] -= 32;
	    else if ($2[i] >= 'A' && $2[i] <= 'Z')
		$2[i] += 32;
	$$ = $2;
    }
| '~' statement {
	char lung[255];
	memset(lung, 0, sizeof(lung));
	sprintf(lung, "%d", strlen($2));
	$$ = lung;
    }
| statement '*' NUMBER {
	char * temp_str = strdup($1);

	if ($3 == 0)
	    temp_str = "";

	for (int i = 1; i < $3; i++)
	    strcat(temp_str, $1);
	$$ = temp_str;
    }
| statement '/' NUMBER {
	char str[255];
	memset(str, 0, sizeof(str));
        
	int index = 0;
	int n = strlen($1);
        
	if (n > $3)
	    for (int i = n - $3; i < n; i++)
		str[index++] = $1[i];
	else
	    strcpy(str, $1);
	$$ = str;
    }
| statement '#' NUMBER {
	char str[255];
	memset(str, 0, sizeof(str));

	if (strlen($1) > $3)
	    strncpy(str, $1, $3);
	else
	   strcpy(str, $1);
	$$ = str;
    }
| statement '+' statement {
        char * temp_str = strdup($1);
        strcat(temp_str, $3);
        $$ = temp_str;
    }
| statement '-' statement {
        char a[255];
        memset(a, 0, sizeof(a));
	strcpy(a, $1);

        char b[255];
        memset(b, 0, sizeof(b));
	strcpy(b, $3);

        char c[100];
	memset(c, 0, sizeof(c));

        while(strstr(a, b) != NULL)
        {
            memset(c, 0, sizeof(c));
            strncpy(c, a, strlen(a) - strlen(strstr(a, b)));
            for (int i = strlen(a) - strlen(strstr(a, b)) + strlen(b); i < strlen(a); i++)
                c[i - strlen(b)] = a[i];
            strcpy(a, c);
        }
        $$ = c;
    }
| statement EQUAL statement {
	char eq[255];
        memset(eq, 0, sizeof(eq));
        sprintf(eq, "%d", strcmp($1, $3));

	if (eq[0] == '0')
	    $$ = "1";
	else
	    $$ = "0";
    }
| statement NOT_EQUAL statement {
	char eq[255];
        memset(eq, 0, sizeof(eq));
        sprintf(eq, "%d", strcmp($1, $3));

        if (eq[0] != '0')
            $$ = "1";
        else
            $$ = "0";
    }
| statement '>' statement {
	if (strcmp($1, $3) > 0)
	    $$ = "1";
	else
	    $$ = "0";
    }
| statement GREATER_OR_EQUAL statement {
	if (strcmp($1, $3) >= 0)
            $$ = "1";
        else
            $$ = "0";
    }
| statement '<' statement {
        if (strcmp($1, $3) < 0)
            $$ = "1";
        else
            $$ = "0";
    }
| statement LESS_OR_EQUAL statement {
        if (strcmp($1, $3) <= 0)
            $$ = "1";
        else
            $$ = "0";
    }
;

id:
  ID {
	$$ = sym[$1];
    }
| VALUE {
	$$ = $1;
    }
;
%%

void yyerror(char * err)
{
    fprintf(yyout, "! ERROR: %s !\n", err);
}

int main(int argc, char * argv[]){

    if (argc == 1) {
	printf("\n+----------------------------------+");
	printf("\n|          PROIECT L.F.T.          |");
	printf("\n+----------------------------------+");
	printf("\n\n\n\n> ");
	
	yyin = stdin;
	yyout = stdout;

	while (!feof(yyin))
	{
            yyparse();
	}
        
        return 1;
    }

    else if (argc == 3) {
        yyin = fopen (argv[1], "r");
        if (yyin == NULL) {
                printf("Eroare la citire din fisier.\n");
                return -1;
        }

        yyout = fopen(argv[2], "w");
        if (yyout == NULL){
                printf("Eroare la scriere in fisier!\n");
                return -2;
        }

        while (!feof(yyin))
        {
            yyparse();
        }

        fclose(yyin);
        fclose(yyout);

        return 1;

        }

        else {
            printf("Numar gresit de argumente!\n");
            return 0;
    }
}
