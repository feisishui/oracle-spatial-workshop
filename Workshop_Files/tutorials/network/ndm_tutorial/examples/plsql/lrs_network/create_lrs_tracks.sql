-- Create LRS_TRACKS table
drop table lrs_tracks;
create table lrs_tracks  (track_id number primary key, 
			  track_name varchar2(64),
			  track_geometry MDSYS.SDO_GEOMETRY);

-- Insert values into  LRS_TRACKS table
-- 2 tracks and 2 cross tracks
insert into lrs_tracks values ( 
                        1,
                        'Track_1',
  			SDO_GEOMETRY(3302,
 				     NULL,
				     NULL,
				     SDO_ELEM_INFO_ARRAY(1,2,1),
				     SDO_ORDINATE_ARRAY(
					4,4,0,
				   	8,4,35,
					10,4,45,
					12,5,55,
					14,5,60,
					20,6,100)
			)
);

insert into lrs_tracks values (
                        2,
                        'Track_2',
  			SDO_GEOMETRY(3302,
 				     NULL,
				     NULL,
				     SDO_ELEM_INFO_ARRAY(1,2,1),
				     SDO_ORDINATE_ARRAY(
					4,10,0,
				   	6,10,3,
					10,10,10,
					12,10,70,
					14,12,85,
					20,12,100)
			)
);


insert into lrs_tracks values (
                        3,
                        'Cross_track_1',
  			SDO_GEOMETRY(3302,
 				     NULL,
				     NULL,
				     SDO_ELEM_INFO_ARRAY(1,2,1),
				     SDO_ORDINATE_ARRAY(
					10,10,0,
					10,4,100)
			)
);

insert into lrs_tracks values (
                        4,
                        'Cross_track_2',
  			SDO_GEOMETRY(3302,
 				     NULL,
				     NULL,
				     SDO_ELEM_INFO_ARRAY(1,2,1),
				     SDO_ORDINATE_ARRAY(
					12,10,0,
					12,5,100)
			)
);

-- update sdo_geom_metadata
delete from user_sdo_geom_metadata where table_name = 'LRS_TRACKS' and column_name = 'TRACK_GEOMETRY';
insert into user_sdo_geom_metadata (table_name,
				    column_name,
				    diminfo,
				    SRID) 
                                    values (
   				    'LRS_TRACKS',
				    'track_geometry',
				    SDO_DIM_ARRAY (
					SDO_DIM_ELEMENT ('X', 0, 100, 0.005),
					SDO_DIM_ELEMENT ('Y', 0, 100, 0.005),
					SDO_DIM_ELEMENT ('M', 0, 100, 0.005)
				    ),
			            NULL
);

-- Create spatial index on track_geometry column

create index lrs_track_index on lrs_tracks(track_geometry) 
indextype is MDSYS.SPATIAL_INDEX;
		
                                    
    			
