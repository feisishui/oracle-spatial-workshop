Set serveroutput on;
Set Timing on;

drop table rdt_IO_Test;

create table rdt_IO_Test of MDSYS.SDO_RASTER
  (primary key (rasterId, pyramidLevel, bandBlockNumber,
                rowBlockNumber, columnBlockNumber))
  lob(rasterblock) store as
  (chunk 8192 nocache nologging pctversion 0 storage (pctincrease 0));

insert into  rdt_io_test values(1, 0, 0, 0,0, null, empty_blob());

Set Timing on;
Declare
  lobsrc BLOB;
  lobdest BLOB;
  buf RAW(31744); --31k --RAW(589824); --64k*9=576k
  bufSize Number;
  nWriteSize  Number;
  nTotal Number;
  nWrite Number;
BEGIN
  bufSize := 31744;
  nTotal := 1073741824;
  nWriteSize := 25600; --8192; --16384; -- 24576; --25600; --31744;
  nWrite := nTotal/nWriteSize;

--Read data into the raw from an exist RDT table
SELECT RASTERBLOCK INTO lobsrc FROM RDT_6
    WHERE rasterid=704 AND Pyramidlevel=0
          AND ROWBLOCKNUMBER=0         
          AND COLUMNBLOCKNUMBER=0
          AND BANDBLOCKNUMBER = 0;
DBMS_LOB.Open(lobsrc, DBMS_LOB.LOB_READONLY);
DBMS_LOB.Read(lobsrc, bufSize, 1, buf);
DBMS_LOB.Close(lobsrc);

-- Get the dest lob
SELECT RASTERBLOCK INTO lobdest FROM RDT_IO_TEST
    WHERE rasterid=1 AND Pyramidlevel=0
          AND ROWBLOCKNUMBER=0         
          AND COLUMNBLOCKNUMBER=0
          AND BANDBLOCKNUMBER = 0 for Update;

-- Write the data out
DBMS_LOB.Open(lobdest, DBMS_LOB.LOB_READWRITE);
For n IN 0..nWrite Loop
	DBMS_LOB.Write(lobdest, nWriteSize, n*nWriteSize + 1, buf);
End Loop;
DBMS_LOB.Close(lobdest);

DBMS_OUTPUT.PUT_LINE('Chunk Size ' || DBMS_LOB.GetChunkSize(lobsrc));
DBMS_OUTPUT.PUT_LINE(DBMS_LOB.GetLength(lobdest));
End;
/
----- 8K Write Buffer ---------
--Elapsed: 00:09:20.98,PM Jan. 9, 2008 WriteSize = 8k  whole script run
--Elapsed: 00:09:13.03,PM Jan. 9, 2008 WriteSize = 8k  whole script run, 2nd
--Elapsed: 00:09:18.58,PM Jan. 9, 2008 WriteSize = 8k  whole script run, 3rd

----- 16K Write Buffer ---------
--Elapsed: 00:04:58.37, PM Jan. 9, 2008 WriteSize = 16k  whole script run
--Elapsed: 00:04:59.67, PM Jan. 9, 2008 WriteSize = 16k  whole script run, 2nd
--Elapsed: 00:04:57.27, PM Jan. 9, 2008 WriteSize = 16k  whole script run, 3rd

----- 24K Write Buffer ---------
--Elapsed: 00:03:34.61, PM Jan. 9, 2008 WriteSize = 24k  whole script run
--Elapsed: 00:03:36.50, PM Jan. 9, 2008 WriteSize = 24k  whole script run, 2nd
--Elapsed: 00:03:53.15, PM Jan. 9, 2008 WriteSize = 24k  whole script run, 3rd
--Elapsed: 00:03:32.95, PM Jan. 9, 2008 WriteSize = 24k  whole script run, 4th

----- 25K Write Buffer ---------
--Elapsed: 00:03:30.87, PM Jan. 9, 2008 WriteSize = 25k  whole script run
--Elapsed: 00:03:26.60, PM Jan. 10, 2008 WriteSize = 25k  whole script run 2nd
--Elapsed: 00:03:28.77, PM Jan. 10, 2008 WriteSize = 25k  whole script run 3rd

----- 31K Write Buffer ---------
--Elapsed: 00:02:53.44, PM Jan. 9, 2008 WriteSize = 31k  whole script run