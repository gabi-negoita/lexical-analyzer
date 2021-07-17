typedef enum { typeCon, typeId, typeOpr, typeNum } nodeEnum;

typedef struct {
	char * value;
} conNodeType;

typedef struct {
	int i;
} idNodeType;

typedef struct {
	int oper;
	int nops;
	struct nodeTypeTag * op[1];
} oprNodeType;

typedef struct {
	int val;
} numNodeType;

typedef struct NodeTypeTag {
	nodeEnum type;
	union {
		conNodeType con;
		idNodeType id;
		oprNodeType opr;
		numNodeType num;
	};
} nodeType;

int ex(nodeType *p);
extern char * sym[52];
