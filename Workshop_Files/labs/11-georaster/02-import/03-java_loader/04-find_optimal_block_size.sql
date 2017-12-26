DECLARE
  dimensionSize    sdo_number_array;
  blockSize        sdo_number_array;
BEGIN
  dimensionSize := sdo_number_array(4299, 4299, 3);
  blockSize := sdo_number_array(512,512,3);
  sdo_geor_utl.calcOptimizedBlockSize(dimensionSize,blockSize);
  dbms_output.put_line('Optimized BlockSize = ('||blockSize(1)||','||blockSize(2)||','||blockSize(3)||')');
END;
/
