create or replace function move_geometry (geom sdo_geometry, shift_x number, shift_y number)
return sdo_geometry
is
begin
  return
    sdo_util.affinetransforms(
      geometry => geom,
      translation => 'TRUE',
        tx => shift_x,
        ty => shift_y,
        tz => 0.0,
      scaling => 'FALSE',
        psc1 => null,
        sx => 0.0,
        sy => 0.0,
        sz => 0.0,
      rotation => 'FALSE',
        p1 => NULL,
        line1 => NULL,
        angle => 0,
        dir => 0,
      shearing => 'FALSE',
        shxy => 0.0,
        shyx => 0.0,
        shxz => 0.0,
        shzx => 0.0,
        shyz => 0.0,
        shzy => 0.0,
      reflection => 'FALSE',
        pref => NULL,
        lineR => NULL,
        dirR => 0,
        planeR => 'FALSE',
        n => SDO_NUMBER_ARRAY(0),
        bigD => SDO_NUMBER_ARRAY(0)
    );
end;
/
