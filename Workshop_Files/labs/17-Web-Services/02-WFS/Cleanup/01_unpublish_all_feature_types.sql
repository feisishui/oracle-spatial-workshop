declare
begin
  for f in (
    select featureTypeId, featureTypeName, dataPointer, namespaceURL
    from mdsys.WFS_FeatureType$
    order by featureTypeId
  )
  loop
    SDO_WFS_PROCESS.dropFeatureType(f.namespaceURL, f.featureTypeName);
    dbms_output.put_line ('Table '|| f.dataPointer || ' unpublished');
  end loop;
end;
/
commit;
