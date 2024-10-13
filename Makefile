SIM ?= iverilog
FILESET = ./fileset.lst
TOPLEVEL = tb_chacha_BLOCK

all : 
	${SIM} -s ${TOPLEVEL} -c ${FILESET} -o ${TOPLEVEL}.out
	./tb_chacha_BLOCK.out
clean:
	rm -rf build/* ${TOPLEVEL}.out
