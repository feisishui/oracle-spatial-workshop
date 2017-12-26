create or replace function optimal_block_size (
  dimensionSize    sdo_number_array,
  blockSize        sdo_number_array
)
return sdo_number_array
as
  newBlockSize sdo_number_array;
begin
  -- The values in the arrays are in row, column, band order
  newBlockSize := blockSize;
  sdo_geor_utl.calcOptimizedBlockSize(dimensionSize,newblockSize);
  return newBlockSize;
END;
/
show errors

-- Example of use:
/*
    <dimensionSize type="ROW">
      <size>12164</size>
    </dimensionSize>
    <dimensionSize type="COLUMN">
      <size>20098</size>
    </dimensionSize>
    <dimensionSize type="BAND">
      <size>3</size>
    </dimensionSize>
*/

select optimal_block_size (sdo_number_array(12164,20098,3), sdo_number_array(512,512,3)) from dual;

-- Which returns:
-- SDO_NUMBER_ARRAY(553, 529, 3)
/*
    <blocking>
      ...
      <type>REGULAR</type>
      <rowBlockSize>553</rowBlockSize>
      <columnBlockSize>529</columnBlockSize>
      <bandBlockSize>3</bandBlockSize>
    </blocking>

*/
