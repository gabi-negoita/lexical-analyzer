%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include "proiect.h"

nodeType * opr(int oper, int nops, ...);
nodeType * id(int i);
nodeType * con(char * value);
nodeType * num(int value);
void freeNode(nodeType *p);
int ex(nodeType *p);
int yylex(void);

void yyerror(char * s);

extern FILE * yyin;
extern FILE * yyout;

char * sym[52];
%}

%union {
    char id;
    char * str;
    int number;
    nodeType *nPtr;
}

%token <id> ID 
%token <str> VALUE
%token <number> NUMBER
%token INCREMENT DECREMENT EQUAL NOT_EQUAL GREATER_OR_EQUAL LESS_OR_EQUAL ENDL

%type <nPtr> statement id assignment num

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
    ex($1); freeNode($1);	
    printf("> ");
    }
| program statement ENDL { 
	ex($2); freeNode($2);
	printf("> ");
    }
| assignment ENDL {
    ex($1); freeNode($1);
	printf("> ");
    }
| program assignment ENDL {
    ex($2); freeNode($2);
	printf("> ");
    }
;

assignment:
  ID '=' statement {        
    $$ = opr('=', 2, id($1), $3);
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
	$$ = opr(INCREMENT, 1, $2);
    }
| statement INCREMENT {
	$$ = opr(INCREMENT, 1, $1);
    }
| DECREMENT statement {
    $$ = opr(DECREMENT, 1, $2);
    }
| statement DECREMENT {
    $$ = opr(DECREMENT, 1, $1);
    }
| '^' statement {
	$$ = opr('^', 1, $2);
    }
| '~' statement {
	$$ = opr('~', 1, $2);
    }
| statement '*' num {
	$$ = opr('*', 2, $1, $3);
    }
| statement '/' num {
	$$ = opr('/', 2, $1, $3);
    }
| statement '#' num {
	$$ = opr('#', 2, $1, $3);
    }
| statement '+' statement {
    $$ = opr('+', 2, $1, $3);
    }
| statement '-' statement {
    $$ = opr('-', 2, $1, $3);
    }
| statement EQUAL statement {
	$$ = opr(EQUAL, 2, $1, $3);
    }
| statement NOT_EQUAL statement {
	$$ = opr(NOT_EQUAL, 2, $1, $3);
    }
| statement '>' statement {
	$$ = opr('>', 2, $1, $3);
    }
| statement GREATER_OR_EQUAL statement {
	$$ = opr(GREATER_OR_EQUAL, 2, $1, $3);
    }
| statement '<' statement {
    $$ = opr('<', 2, $1, $3);
    }
| statement LESS_OR_EQUAL statement {
       $$ = opr(LESS_OR_EQUAL, 2, $1, $3);
    }
;

id:
  ID {
	$$ = id($1);
    }
| VALUE {
	$$ = con($1);
    }
;

num:
NUMBER {
    $$ = num($1);
}
;
%%

nodeType *con(char * value) {
	nodeType *p;
	if ((p = malloc(sizeof(nodeType))) == NULL)
		yyerror("out of memory1");
	p->type = typeCon;
	p->con.value = value;
	
	return p;
}

nodeType *id (int i) {
	nodeType *p;
	
	if((p = malloc(sizeof(nodeType))) == NULL)
		yyerror("out of memory2");
	p->type = typeId;
	p->id.i = i;
	
	return p;
}

nodeType *num(int value) {
	nodeType *p;
	if ((p = malloc(sizeof(nodeType))) == NULL)
		yyerror("out of memory1");
	p->type = typeNum;
	p->num.val = value;
	
	return p;
}
	
nodeType *opr(int oper, int nops, ...) {
	va_list ap;
	nodeType *p;
	int i;
	
	if ((p = malloc(sizeof(nodeType) + (nops - 1) * sizeof(nodeType *))) == NULL)
		yyerror("out of memory3");
	p->type = typeOpr;
	p->opr.oper = oper;
	p->opr.nops = nops;
	va_start(ap, nops);
	for (int i = 0; i < nops; i++)
		p->opr.op[i] = va_arg(ap, nodeType*);
	va_end(ap);
	return p;
}

void freeNode(nodeType *p) {
	int i;
	if (!p) return;
	if (p->type == typeOpr) {
		for (int i = 0; i < p->opr.nops; i++)
			freeNode(p->opr.op[i]);
	}
	free(p);
}

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
