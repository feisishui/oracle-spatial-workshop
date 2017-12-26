INC =   -I.

EXE =   shp2sdo

SRC =   shp2sdo.c shpopen.c dbfopen.c

OBJ =   shp2sdo.o shpopen.o dbfopen.o

#DEBUG =  -g -DDEBUG
CFLAGS =  $(DEBUG) $(INC)
LDFLAGS = -lm

all : $(EXE)

$(EXE) : $(OBJ)
	$(CC) $(CFLAGS) -o $@ $(OBJ) $(LDFLAGS)

clean :
	$(RM) $(OBJ)
	$(RM) $(EXE)

install :
	@echo Nothing to install
