declare
  bf  BFILE;
  cl  CLOB;
  src_offset    number;
  dest_offset   number;
  lang_context  number;
  warning       number;
begin
  for j in (select * from fields for update)
  loop
    bf := bfilename ('KML_DATA_DIR', j.file_name);
    cl := j.kml;
    DBMS_LOB.fileopen(bf, DBMS_LOB.file_readonly);
    dest_offset := 1;
    src_offset := 1;
    lang_context :=0;
    dbms_lob.loadclobfromfile (
       dest_lob       => cl, 
       src_bfile      => bf, 
       amount         => DBMS_LOB.LOBMAXSIZE, 
       dest_offset    => dest_offset, 
       src_offset     => src_offset,
       bfile_csid     => 0,
       lang_context   => lang_context,
       warning        => warning
    );
    DBMS_LOB.fileclose (bf);
    update fields set kml = cl where id = j.id;
  end loop;
end;
/
show errors
