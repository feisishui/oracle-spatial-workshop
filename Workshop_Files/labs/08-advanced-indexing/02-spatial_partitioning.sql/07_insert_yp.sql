INSERT INTO yellow_pages_part_spatial (id, name, category, location)
  VALUES (457840, 'NATURE FOODS GROCERY', 4, SDO_GEOMETRY(2001, 8307, SDO_POINT_TYPE(-74.01, 40.682, NULL), NULL, NULL));

INSERT INTO yellow_pages_part_spatial (id, name, category, location)
  VALUES (457841, 'HILTON HOTEL', 5, SDO_GEOMETRY(2001, 8307, SDO_POINT_TYPE(-73.823, 40.445, NULL), NULL, NULL));
COMMIT;

SELECT id, name, cell_id
FROM yellow_pages_part_spatial
WHERE id >= 457840;
