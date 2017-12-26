CREATE OR REPLACE PROCEDURE format_geo_addr (
  address SDO_GEO_ADDR
)
AS
  type strings is table of varchar2(60);
  accuracies strings := strings (
    '0 = POI',
    '1 = Exact house address',
    '2 = Interpolated house address',
    '3 = Street',
    '4 = Postal code',
    '5 = Settlement',
    '6 = Municipality',
    '7 = Region',
    '8 = Country'
  );
  match_names strings := strings (
    '?            ',
    '0 (MATCHED)  ',
    '1 (ABSENT)   ',
    '2 (CORRECTED)',
    '3 (IGNORED)  ',
    '4 (SUPPLIED) '
  );
  address_elements strings := strings (
    null,
    null,
    'X Address Point',
    'O POI Name',
    '# House or building number',
    'E Street prefix',
    'N Street base name',
    'U Street suffix',
    'T Street type',
    'S Secondary unit',
    'B Built-up area or city',
    null,
    null,
    '1 Region',
    'C Country',
    'P Postal code',
    'P Postal add-on code'
  );
  element_match varchar2(128);
  element_match_code char(1);

BEGIN
  if address is not null then
    dbms_output.put_line ('- ID                  ' || address.ID);
    dbms_output.put_line ('- ADDRESSLINES');
    if address.addresslines is not null then
      for i in 1..address.addresslines.count() loop
        dbms_output.put_line ('- ADDRESSLINES['||i||']           ' || address.ADDRESSLINES(i));
      end loop;
    end if;
    dbms_output.put_line ('- PLACENAME           ' || address.PLACENAME);
    dbms_output.put_line ('- STREETNAME          ' || address.STREETNAME);
    dbms_output.put_line ('- INTERSECTSTREET     ' || address.INTERSECTSTREET);
    dbms_output.put_line ('- SECUNIT             ' || address.SECUNIT);
    dbms_output.put_line ('- SETTLEMENT          ' || address.SETTLEMENT);
    dbms_output.put_line ('- MUNICIPALITY        ' || address.MUNICIPALITY);
    dbms_output.put_line ('- REGION              ' || address.REGION);
    dbms_output.put_line ('- COUNTRY             ' || address.COUNTRY);
    dbms_output.put_line ('- POSTALCODE          ' || address.POSTALCODE);
    dbms_output.put_line ('- POSTALADDONCODE     ' || address.POSTALADDONCODE);
    dbms_output.put_line ('- FULLPOSTALCODE      ' || address.FULLPOSTALCODE);
    dbms_output.put_line ('- POBOX               ' || address.POBOX);
    dbms_output.put_line ('- HOUSENUMBER         ' || address.HOUSENUMBER);
    dbms_output.put_line ('- BASENAME            ' || address.BASENAME);
    dbms_output.put_line ('- STREETTYPE          ' || address.STREETTYPE);
    dbms_output.put_line ('- STREETTYPEBEFORE    ' || address.STREETTYPEBEFORE);
    dbms_output.put_line ('- STREETTYPEATTACHED  ' || address.STREETTYPEATTACHED);
    dbms_output.put_line ('- STREETPREFIX        ' || address.STREETPREFIX);
    dbms_output.put_line ('- STREETSUFFIX        ' || address.STREETSUFFIX);
    dbms_output.put_line ('- SIDE                ' || address.SIDE);
    dbms_output.put_line ('- PERCENT             ' || address.PERCENT);
    dbms_output.put_line ('- EDGEID              ' || address.EDGEID);
    dbms_output.put_line ('- ERRORMESSAGE        ' || address.ERRORMESSAGE);
    if address.MATCHVECTOR is not null then
      dbms_output.put_line ('- MATCHVECTOR         ' || address.MATCHVECTOR);
      for i in 1..length(address.MATCHVECTOR) loop
        if address_elements(i) is not null then
          if substr (address.matchvector,i,1) = '?' then
            element_match_code := 0;
          else
            element_match_code := substr(address.matchvector,i,1) + 1;
          end if;
          dbms_output.put_line ('-   ' || rpad ('[' || i || ']',5) || substr(address.errormessage,i,1)  || ' ' ||
            match_names (element_match_code + 1) || ' ' ||
            address_elements (i)
          );
        end if;
      end loop;
    end if;
    if address.MATCHVECTOR is not null then
      dbms_output.put_line ('- MATCHCODE           ' || address.MATCHCODE || ' = ' ||
        case address.MATCHCODE
          when  0 then 'Ambiguous'
          when  1 then 'Exact match'
          when  2 then 'Street type not matched'
          when  3 then 'House number not matched'
          when  4 then 'Street name not matched'
          when 10 then 'Postal code not matched'
          when 11 then 'City not matched'
        end
      );
    end if;
    dbms_output.put_line ('- ACCURACY            ' || accuracies (gc_accuracy(address)+1));
    dbms_output.put_line ('- MATCHMODE           ' || address.MATCHMODE);
    dbms_output.put_line ('- LONGITUDE           ' || address.LONGITUDE);
    dbms_output.put_line ('- LATITUDE            ' || address.LATITUDE);
    dbms_output.put_line ('- SRID                ' || address.SRID);
  else
    dbms_output.put_line ('**** NO MATCH ****');
  end if;
end;
/
show errors

create or replace procedure format_addr_array (
  address_list SDO_ADDR_ARRAY
)
as
begin
  if address_list is not null and address_list.count() > 0 then
    for i in 1..address_list.count() loop
      dbms_output.put_line ('ADDRESS['||i||']');
      format_geo_addr (address_list(i));
    end loop;
  else
    dbms_output.put_line ('**** NO MATCH ****');
  end if;
end;
/
show errors
