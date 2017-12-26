INC =   -I.

EXE =   shp2sdo

SRC =   shp2sdo.c shpopen.c dbfopen.c

OBJ =   shp2sdo.o shpopen.o dbfopen.o

#DEBUG =  -g -DDEBUG
# The -mno-cygwin is for building on WIN32 using GCC / cygwin32
# without requiring the cygnus.dll for execution
CFLAGS =  $(DEBUG) $(INC) -mno-cygwin
LDFLAGS = -lm

all : $(EXE)

$(EXE) : $(OBJ)
	$(CC) $(CFLAGS) -o $@ $(OBJ) $(LDFLAGS)

clean :
	$(RM) $(OBJ)
	$(RM) $(EXE)

install :
	@echo Nothing to install
