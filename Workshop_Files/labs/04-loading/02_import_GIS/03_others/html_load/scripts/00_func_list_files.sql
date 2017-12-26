create or replace and compile java source named "ListFiles"
as
import java.io.*;
public class ListFiles
{
  public static String get (String directory) 
  throws Exception {
    File path = new File( directory );
    String[] list = path.list();
    String csvList = "";
    for(int i = 0; i < list.length; i++) {
      csvList = csvList + list[i] +",";
    }
    return csvList;
  }
}
/
show errors


create or replace function list_files_get( fs_directory in varchar2)
return varchar2
as language java name 'ListFiles.get(java.lang.String) return java.lang.String';
/
show error

create or replace function list_files (ora_directory varchar2) return sdo_keywordarray
as
  fs_directory varchar2(4000);
  csv_list clob;
  file_name varchar2(128);
  file_names sdo_keywordarray := sdo_keywordarray();
  i integer;
  j integer;
  k integer;
begin
  -- Get the file system directory for the oracle directory
  begin
    select directory_path 
    into fs_directory
    from all_directories 
    where directory_name = ora_directory;
  exception
    when no_data_found then
      return null;
  end;
  -- Get the list of files in that directory as a CSV
  csv_list := list_files_get (fs_directory);
  -- Split the csv list into an array
  i := 1;
  j := instr(csv_list,',');
  k := 1;
  while j > 0 loop
    file_name := substr(csv_list, i, j-1);
    file_names.extend();
    file_names(k) := file_name;
    k := k+1;
    i := i+j;
    j := instr(substr(csv_list,i),',');
  end loop;
  -- Return the array
  return file_names;
end;
/
show error
