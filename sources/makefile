all:
	bison -dv proiect.y >1
	flex -oproiect.yy.c proiect.l
	gcc -w -o proiect.exe proiect.tab.c proiect.yy.c -lfl -ly
	./proiect.exe

graph:
	bison -dv graphic/proiect.y -o ./graphic/proiect.tab.c
	flex -o./graphic/proiect.yy.c graphic/proiect.l
	gcc -w -o graphic/proiect.exe graphic/proiect.tab.c graphic/proiect.yy.c graphic/proiect.c -lfl -ly
	./graphic/proiect.exe

clear:
	find . -type f ! -name '*.txt' ! -name '*.l' ! -name '*.y' ! -name 'proiect.h' ! -name 'proiect.c' ! -name 'makefile' -delete
