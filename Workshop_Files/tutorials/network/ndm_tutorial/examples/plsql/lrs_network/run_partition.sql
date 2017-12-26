-- run spatial partition procedure on lrs_track network
-- Max size is set to 100

-- Requires CREATE VIEW privilege ane write permission to work_dir.
exec sdo_net.spatial_partition('LRS_TRACK','LRS_TRACK_PART$',100,'WORK_DIR','lrspart.log','a');

-- Generate partition blob
exec sdo_net.generate_partition_blobs('LRS_TRACK',1,'LRS_TRACK_PBLOB$',true,true,'WORK_DIR','lrstrackpblob.log','a');
