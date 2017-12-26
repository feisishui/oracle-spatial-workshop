/*
How to query using getrastersubset and read cells into memory as numbers

Note, This example code queries and crops a raster using a window and then reads cells 
in the resulting BLOB one by one and print out the numbers. 

If needed, put the numbers into an array as you wish.

Also this script deals with different cell depths. If cell depth is only one byte or one 
type, the script can be much simplified.

Example of use:

select getCellValue(georaster,0,0,sdo_number_array(0,0,4,4)) 
from georaster_table 
where georid=1;

*/

create or replace function getCellValue (
  gr sdo_georaster, 
  pl number,
  bno number, 
  win sdo_number_array
)
return number 
as
  cdp  varchar2(80);
  flt  number := 0;
  cdl  number;
  parm varchar(200);
  lb   blob;
  buf  raw(32767);
  r1   raw(1);
  r2   raw(2);
  r4   raw(4);
  r8   raw(8);
  amt0 integer;
  amt  integer;
  off  integer;
  len  integer;
  maxv number := null;
  val  number;
begin

  cdp := gr.metadata.extract('/georasterMetadata/rasterInfo/cellDepth/text()',
            'xmlns=http://xmlns.oracle.com/spatial/georaster').getStringVal();

  if cdp = '32BIT_REAL' then
    flt := 1;
  end if;
  cdl := sdo_geor.getCellDepth(gr);
  
  -- to simplify, cast cells of less than 8 bit into bytes (8 bit unsigned integers)
  if cdl < 8 then
    cdl := 8;
    parm := 'celldepth=8bit_u';
  end if;

  parm := parm || ' compression=none';

  dbms_lob.createTemporary(lb, true);

  sdo_geor.getRasterSubset(gr,pl,win,to_char(bno),lb,parm);
  len := dbms_lob.getlength(lb);

  dbms_output.put_line('lob length: ' || len);

  cdl := cdl / 8;

  amt := floor(32767 / cdl) * cdl;
  amt0 := amt;

  off := 1;
  while off <= len loop
    dbms_lob.read(lb, amt, off, buf);
    for i in 1..amt/cdl loop
      if cdl = 1 then
        r1 := utl_raw.substr(buf, (i-1)*cdl+1, cdl);
        val := utl_raw.cast_to_binary_integer(r1);
      elsif cdl = 2 then
        r2 := utl_raw.substr(buf, (i-1)*cdl+1, cdl);
        val := utl_raw.cast_to_binary_integer(r2);
      elsif cdl = 4 then
        r4 := utl_raw.substr(buf, (i-1)*cdl+1, cdl);
        if flt = 0 then
          val := utl_raw.cast_to_binary_integer(r4);
        else
          val := utl_raw.cast_to_binary_float(r4);
        end if;
      elsif cdl = 8 then
        r8 := utl_raw.substr(buf, (i-1)*cdl+1, cdl);
        val := utl_raw.cast_to_binary_double(r8);
      end if;
      dbms_output.put_line(val||'--');
    end loop;
    off := off+amt;
    amt := amt0;
  end loop;

  dbms_lob.freeTemporary(lb);

  return 1;

end;
/
show errors;
