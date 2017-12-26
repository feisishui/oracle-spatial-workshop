drop table lrs_track_node$;
drop table lrs_track_link$;

create table lrs_track_node$ (node_id number primary key,
			      node_name varchar2(32),
			      track_id number,
			      measure number,
			      geometry SDO_GEOMETRY,
			      partition_id number);

create table lrs_track_link$ (link_id number primary key,
			      link_name varchar2(32),
			      start_node_id number,
			      end_node_id number,
			      link_level number,
			      track_id number,
			      start_measure number,
			      end_measure number,
			      geometry SDO_GEOMETRY,
 			      cost number);

-- populate node and link tables except geometry column.
-- Geometry column populated from LRS_TRACKS table.

-- Node N1: Same as track 1 point 1 : Start point of track 1
insert into lrs_track_node$ (node_id, track_id, measure)
                           values (1,1,0);

-- Node N6 : Same as track1 point 3
insert into lrs_track_node$ (node_id, track_id, measure)
                           values (6,1,45);
-- Node N8 : Same as track1 point 4
insert into lrs_track_node$ (node_id, track_id, measure)
                           values (8,1,55);
		
-- Node N2 : Same as track1 point 6 : End point of track 1
insert into lrs_track_node$ (node_id, track_id, measure)
                           values (2,1,100);

-- Node N3 : Same as track2 point 1 : Start point of track2
insert into lrs_track_node$ (node_id, track_id, measure)
                           values (3,2,0);

-- Node N5 : Same as track2 point 3
insert into lrs_track_node$ (node_id, track_id, measure)
                           values (5,2,10);

-- Node N7 : Same as track2 point 4
insert into lrs_track_node$ (node_id, track_id, measure)
                           values (7,2,70);

-- Node N4 : Same as track2 point 6 : End of track2
insert into lrs_track_node$ (node_id, track_id, measure)
                           values (4,2,100);
	
-- Links 

-- Link 1 from N1 to N6; Three points on the link

insert into lrs_track_link$ (link_id,
			     start_node_id,
			     end_node_id,
			     link_level,
			     track_id,
			     start_measure,
			     end_measure)
			     values
			     (1, 1, 6, 1, 1, 0, 45);

-- Link 2 from N6 to N2; Four point on the link

insert into lrs_track_link$ (link_id,
                             start_node_id,
                             end_node_id,
                             link_level,
                             track_id,
			     start_measure,
			     end_measure)
                             values
                             (2, 6, 2, 1, 1, 45, 100);

-- Link 3 from N3 to N5; Three points

insert into lrs_track_link$ (link_id,
                             start_node_id,
                             end_node_id,
                             link_level,
                             track_id,
			     start_measure,
			     end_measure)
                             values
                             (3, 3, 5, 1, 2, 0, 10);
			    
-- Link 4 from N5 to N4; four points

insert into lrs_track_link$ (link_id,
                             start_node_id,
                             end_node_id,
                             link_level,
                             track_id,
			     start_measure,
			     end_measure)
                             values
                             (4, 5, 4, 1, 2, 10, 100);

-- Link 5 from N5 to N6; Cross track; two points

insert into lrs_track_link$ (link_id,
                             start_node_id,
                             end_node_id,
                             link_level,
                             track_id,
			     start_measure,
			     end_measure)
                             values
                             (5, 5, 6, 1, 3, 0, 100);

-- Link 6 from N7 to N8; Cross track; two points

insert into lrs_track_link$ (link_id,
                             start_node_id,
                             end_node_id,
                             link_level,
                             track_id,
			     start_measure,
			     end_measure)
                             values
                             (6, 7, 8, 1, 4, 0, 100);

-- Link 7 from N4 to N7; three points

insert into lrs_track_link$ (link_id,
                             start_node_id,
                             end_node_id,
                             link_level,
                             track_id,
			     start_measure,
			     end_measure)
                             values
                             (7, 4, 7, 1, 2, 100, 70);

-- Link 8 from N8 to N1; 4 points

insert into lrs_track_link$ (link_id,
                             start_node_id,
                             end_node_id,
                             link_level,
                             track_id,
			     start_measure,
			     end_measure)
                             values
                             (8, 8, 1, 1, 1, 55, 0);

-- Link 9 from N2 to N8; 3 points

insert into lrs_track_link$ (link_id,
                             start_node_id,
                             end_node_id,
                             link_level,
                             track_id,
			     start_measure,
			     end_measure)
                             values
                             (9, 2, 8, 1, 1, 100, 55);

-- create path table to store network analysis results

drop table lrs_track_path$ purge;
drop table lrs_track_spath$ purge;

create table lrs_track_path$   (path_id number,
				path_name varchar2(256),
				path_type varchar2(256),
				start_node_id number,
				end_node_id number,
				cost number,
				simple varchar2(3),
				path_geometry mdsys.sdo_geometry);

-- create sub path table to store network analysis results

create table lrs_track_spath$ (subpath_id number,
				subpath_name varchar2(256),
				subpath_type varchar2(256),
				reference_path_id number,
				start_link_index number,
				end_link_index number,
				start_percentage number,
				end_percentage number,
				cost number,
				geometry mdsys.sdo_geometry);

--
-- Use LRS to generate the geometry representation of each track node.
--
update lrs_track_node$ a
set a.geometry = (SELECT sdo_lrs.convert_to_std_geom (
                           sdo_lrs.locate_pt (b.track_geometry, a.measure))
                  FROM lrs_tracks b
                  WHERE b.track_id = a.track_id);

 
--
-- Use LRS to generate the geometry representation of each track link.
--
update lrs_track_link$ a
set a.geometry = (SELECT sdo_lrs.convert_to_std_geom (
                           sdo_lrs.clip_geom_segment (b.track_geometry, 
                                                      a.start_measure,
                                                      a.end_measure))
                  FROM lrs_tracks b
                  WHERE b.track_id = a.track_id); 

--
-- User the link geometry to compute the cost of link
--
update lrs_track_link$ b
set cost = (select sdo_geom.sdo_length(a.geometry, m.diminfo)
            from lrs_track_link$ a, user_sdo_geom_metadata m
            where m.table_name = 'LRS_TRACK_LINK$'
                  and a.link_id = b.link_id);

-- register network tables in sdo_network_metadata

delete from user_sdo_network_metadata where network = 'LRS_TRACK';

insert into user_sdo_network_metadata (network,
			               network_id,
				       network_category,
				       lrs_table_name,
				       lrs_geom_column,
				       node_table_name,
				       node_geom_column,
				       link_table_name,
				       link_direction,
				       link_cost_column,
				       link_geom_column,
				       path_table_name,
				       path_geom_column,
				       path_link_table_name,
				       subpath_table_name,
				       subpath_geom_column)
				       values
				       ('lrs_track',
					1001,
				        'spatial',
				        'lrs_tracks',
					'track_geometry',
					'lrs_track_node$',
					'geometry',
					'lrs_track_link$',
					'directed',
					'cost',
				        'geometry',
					'lrs_track_path$',
					'path_geometry',
					'lrs_track_plink$',
					'lrs_track_spath$',
					'geometry'
				        );
				        
-- register in sdo_geom_metadata

delete from user_sdo_geom_metadata where table_name in ('LRS_TRACK_NODE$',
                                                        'LRS_TRACK_LINK$',
                                                        'LRS_TRACK_PATH$',
                                                        'LRS_TRACK_SPATH$')
                                     and column_name in ('GEOMETRY', 'PATH_GEOMETRY');

insert into user_sdo_geom_metadata (table_name, column_name, diminfo, srid) 
				    values
				   ('LRS_TRACK_NODE$',
				    'GEOMETRY',
				    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X',0,100,0.005),
					  	      SDO_DIM_ELEMENT('Y',0,100,0.005)),
				    NULL
 				   );
				   
insert into user_sdo_geom_metadata (table_name, column_name, diminfo, srid) 
				    values
				   ('LRS_TRACK_LINK$',
				    'GEOMETRY',
				    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X',0,100,0.005),
					  	  SDO_DIM_ELEMENT('Y',0,100,0.005)),
				    NULL
 				   );

insert into user_sdo_geom_metadata (table_name,column_name,diminfo,srid)
				   values
				   ('LRS_TRACK_PATH$',
				    'PATH_GEOMETRY',
				    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 0, 100, .005),
						  SDO_DIM_ELEMENT('Y',0,100,0.005)),
				    NULL);
insert into user_sdo_geom_metadata (table_name,column_name,diminfo,srid)
                                   values
                                   ('LRS_TRACK_SPATH$',
                                    'GEOMETRY',
                                    SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 0, 100, .005),
                                                  SDO_DIM_ELEMENT('Y',0,100,0.005)),
                                    NULL);
