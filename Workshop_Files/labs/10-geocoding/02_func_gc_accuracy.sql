CREATE OR REPLACE FUNCTION gc_accuracy (
  address SDO_GEO_ADDR
)
RETURN number
AS
BEGIN
  /*
  
  Meaning of the accuracy values:
  Match
  Level   Description                 Origin table      Notes
  -----   --------------------------  ----------------  ----------------------------
    0     POI                         GC_POI
    1     Exact house address         GC_ADDRESS_POINT
    2     Interpolated house address  GC_ROAD_SEGMENT   (By interpolating the house number)
    3     Street                      GC_ROAD           (center, start or house number on that road). This happens if the input address has no house number, or if the house number does not exist on that road.
    4     Postal code                 GC_POSTAL_CODE
    5     Settlement                  GC_AREA           settlement record
    6     Municipality                GC_AREA           municipality record
    7     Region                      GC_AREA           region record
    8     Country                     GC_AREA           country record
    
  Structure of the match vector: 
  Position	Use 
  --------  ------------------------------------ 
   [3]      X Address Point
   [4]      O POI Name
   [5]      # House or building number
   [6]      E Street prefix
   [7]      N Street base name
   [8]      U Street suffix
   [9]      T Street type
   [10]     S Secondary unit
   [11]     B Built-up area or city
   [14]     1 Region
   [15]     C Country 
   [16]     P Postal code
   [17]     P Postal add-on code
   
   Meaning of match vector values:
   Value    Meaning
   ------   --------------------
   0 		MATCHED
   1 		ABSENT
   2 		CORRECTED
   3 		IGNORED
   4 		SUPPLIED

  */
  -- POI matched (GC_POI)
  if substr(address.MATCHVECTOR,4,1) = '0' then
    return 0;
  end if;

  -- Exact house number match (GC_ADDRESS_POINT)
  -- Only if the supplied house number was used
  -- The match vector will also indicate a point address match when we use one of the
  -- default numbers in GC_ROAD and that number happens to be in the address point table.
  if substr(address.MATCHVECTOR,3,1) = '0' and 
     substr(address.MATCHVECTOR,5,1) = '0' then
    return 1;
  end if;

  -- Interpolated house number match (GC_ROAD_SEGMENT)
  if substr(address.MATCHVECTOR,5,1) = '0' then
    return 2;
  end if;

  -- Street matched or corrected but house number not matched (GC_ROAD)
  if substr(address.MATCHVECTOR,7,1) in ('0','2') and substr(address.MATCHVECTOR,5,1) <> '0' then
    return 3;
  end if;

  -- Street not matched (GC_POSTAL_CODE or GC_AREA)
  if substr(address.MATCHVECTOR,7,1) <> '0'  then
    -- Postal code matched
    if substr(address.MATCHVECTOR,16,1) = '0'  then
      return 4;
    end if;
    -- Settlement or municipality  matched
    -- Note; only one code passed in MATCHVECTOR: distinguishing a settlement from a municipality match is not possible
    -- We assume that the match is on the settlement level
    if substr(address.MATCHVECTOR,11,1) = '0'  then
      return 5;
    end if;
    -- Region matched
    if substr(address.MATCHVECTOR,14,1) = '0'  then
      return 7;
    end if;
  end if;

  -- Default is country level match
  return 8;

END;
/
show errors
CREATE OR REPLACE FUNCTION gc_accuracy_string (
  accuracy NUMBER
)
RETURN varchar2
AS
  type strings is table of varchar2(30);
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
BEGIN
  return accuracies(accuracy+1);
END;
/
show error
