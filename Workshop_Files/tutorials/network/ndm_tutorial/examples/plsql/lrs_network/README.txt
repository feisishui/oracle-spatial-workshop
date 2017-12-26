This directory has the SQL scripts to create LRS and network tables.

Run the scripts in the following order.

(0) create_user.sql
    Creates a user called mdnetwork to contain the data for this demo.

    As a DBA user:
     -- Create a directory. For this example, the directory is called WORK_DIR.
        Log files will be written to WORK_DIR. 
     -- Create a user with connect,resource,create view privileges.
        Also, grant read, write priviliges on WORK_DIR to mdnetwork. 

(1) create_lrs_tracks.sql  
    This creates the LRS table LRS_TRACKS for the track information. 
    It also registers the table in the geom metatdata.

(2) create_network_tables.sql
    Creates the node and link tables corresponding to the LRS track tables.
    (LRS_TRACK_NODE$ and LRS_TRACK_LINK$ respectively)

    The geometry columns of these tables are populated based on the LRS 
    measures in the LRS_TRACKS table.

    The geometry columns are converted to sdo_geometry from lrs geometry.

    The cost of every link in the link table is computed from the geometry 
    of the link.

    Ths script also creates the required path and subpath tables 
    (LRS_TRACK_PATH$ and LRS_TRACK_SPATH$ respectively) to store network
    analysis results.

    The network tables are registered in user_sdo_network_metadata and 
    user_sdo_geom_metadata.

 (3)run_partition.sql
    This runs the spatial partitioning procedure and generates the partition
    blob. 
    
