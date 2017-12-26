Rem
Rem $Header: sdo/demo/network/examples/data/util/daee/create_indexes.sql /main/1 2012/03/08 05:58:44 begeorge Exp $
Rem
Rem create_indexes.sql
Rem
Rem Copyright (c) 2012, Oracle and/or its affiliates. All rights reserved. 
Rem
Rem    NAME
Rem      create_indexes.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    begeorge    03/07/12 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

-- Register tables in geom_metadata
delete from user_sdo_geom_metadata where table_name='DAEE_NODE$';
insert into user_sdo_geom_metadata
(table_name, column_name, diminfo, srid)
values
('DAEE_NODE$', 'GEOMETRY',
  SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 173618.078, 194805.785, .00000005),
               SDO_DIM_ELEMENT('Y', 1653028.55, 1683487.84, .00000005)),
 81989002);

delete from user_sdo_geom_metadata where table_name='DAEE_LINK$';
insert into user_sdo_geom_metadata
(table_name, column_name, diminfo, srid)
values
('DAEE_LINK$', 'GEOMETRY',
  SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 173618.078, 194805.785, .00000005),
               SDO_DIM_ELEMENT('Y', 1653028.55, 1683487.84, .00000005)),
 81989002);

commit;

-- Following tables are required for the map
delete from user_sdo_geom_metadata where table_name='G_CAP';
insert into user_sdo_geom_metadata
(table_name, column_name, diminfo, srid)
values
('G_CAP', 'GEOM',
 SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 173618.078, 194805.785, .00000005), SDO_DIM_ELEMENT('Y', 1653028.55, 1683487.84, .00000005)),
 81989002);

delete from user_sdo_geom_metadata where table_name='G_CURVA';
insert into user_sdo_geom_metadata
(table_name, column_name, diminfo, srid)
values
('G_CURVA', 'GEOM',
 SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 173618.078, 194805.785, .00000005), SDO_DIM_ELEMENT('Y', 1653028.55, 1683487.84, .00000005)),
 81989002);

delete from user_sdo_geom_metadata where table_name='G_CURVA_11';
insert into user_sdo_geom_metadata
(table_name, column_name, diminfo, srid)
values
('G_CURVA_11', 'GEOM',
 SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 173618.078, 194805.785, .00000005), SDO_DIM_ELEMENT('Y', 1653028.55, 1683487.84, .00000005)),
 81989002);

delete from user_sdo_geom_metadata where table_name='G_CURVA_22';
insert into user_sdo_geom_metadata
(table_name, column_name, diminfo, srid)
values
('G_CURVA_22', 'GEOM',
 SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 173618.078, 194805.785, .00000005), SDO_DIM_ELEMENT('Y', 1653028.55, 1683487.84, .00000005)),
 81989002);

delete from user_sdo_geom_metadata where table_name='G_CURVA_30';
insert into user_sdo_geom_metadata
(table_name, column_name, diminfo, srid)
values
('G_CURVA_30', 'GEOM',
 SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 173618.078, 194805.785, .00000005), SDO_DIM_ELEMENT('Y', 1653028.55, 1683487.84, .00000005)),
 81989002);

delete from user_sdo_geom_metadata where table_name='G_CURVA_45';
insert into user_sdo_geom_metadata
(table_name, column_name, diminfo, srid)
values
('G_CURVA_45', 'GEOM',
 SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 173618.078, 194805.785, .00000005), SDO_DIM_ELEMENT('Y', 1653028.55, 1683487.84, .00000005)),
 81989002);

delete from user_sdo_geom_metadata where table_name='G_CURVA_90';
insert into user_sdo_geom_metadata
(table_name, column_name, diminfo, srid)
values
('G_CURVA_90', 'GEOM',
 SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 173618.078, 194805.785, .00000005), SDO_DIM_ELEMENT('Y', 1653028.55, 1683487.84, .00000005)),
 81989002);

delete from user_sdo_geom_metadata where table_name='G_CRUZETA';
insert into user_sdo_geom_metadata
(table_name, column_name, diminfo, srid)
values
('G_CRUZETA', 'GEOM',
 SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 173618.078, 194805.785, .00000005), SDO_DIM_ELEMENT('Y', 1653028.55, 1683487.84, .00000005)),
 81989002);

delete from user_sdo_geom_metadata where table_name='G_REDUCAO';
insert into user_sdo_geom_metadata
(table_name, column_name, diminfo, srid)
values
('G_REDUCAO', 'GEOM',
 SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 173618.078, 194805.785, .00000005), SDO_DIM_ELEMENT('Y', 1653028.55, 1683487.84, .00000005)),
 81989002);

delete from user_sdo_geom_metadata where table_name='G_TE';
insert into user_sdo_geom_metadata
(table_name, column_name, diminfo, srid)
values
('G_TE', 'GEOM',
 SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 173618.078, 194805.785, .00000005), SDO_DIM_ELEMENT('Y', 1653028.55, 1683487.84, .00000005)),
 81989002);

delete from user_sdo_geom_metadata where table_name='G_LUVA';
insert into user_sdo_geom_metadata
(table_name, column_name, diminfo, srid)
values
('G_LUVA', 'GEOM',
 SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 173618.078, 194805.785, .00000005), SDO_DIM_ELEMENT('Y', 1653028.55, 1683487.84, .00000005)),
 81989002);

delete from user_sdo_geom_metadata where table_name='G_TAP';
insert into user_sdo_geom_metadata
(table_name, column_name, diminfo, srid)
values
('G_TAP', 'GEOM',
 SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 173618.078, 194805.785, .00000005), SDO_DIM_ELEMENT('Y', 1653028.55, 1683487.84, .00000005)),
 81989002);

delete from user_sdo_geom_metadata where table_name='G_ADAPTADOR';
insert into user_sdo_geom_metadata
(table_name, column_name, diminfo, srid)
values
('G_ADAPTADOR', 'GEOM',
 SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 173618.078, 194805.785, .00000005), SDO_DIM_ELEMENT('Y', 1653028.55, 1683487.84, .00000005)),
 81989002);

delete from user_sdo_geom_metadata where table_name='G_EMBUTIDO';
insert into user_sdo_geom_metadata
(table_name, column_name, diminfo, srid)
values
('G_EMBUTIDO', 'GEOM',
 SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 173618.078, 194805.785, .00000005), SDO_DIM_ELEMENT('Y', 1653028.55, 1683487.84, .00000005)),
 81989002);

delete from user_sdo_geom_metadata where table_name='G_FERRULE';
insert into user_sdo_geom_metadata
(table_name, column_name, diminfo, srid)
values
('G_FERRULE', 'GEOM',
 SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 173618.078, 194805.785, .00000005), SDO_DIM_ELEMENT('Y', 1653028.55, 1683487.84, .00000005)),
 81989002);

delete from user_sdo_geom_metadata where table_name='G_FLANGE';
insert into user_sdo_geom_metadata
(table_name, column_name, diminfo, srid)
values
('G_FLANGE', 'GEOM',
 SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 173618.078, 194805.785, .00000005), SDO_DIM_ELEMENT('Y', 1653028.55, 1683487.84, .00000005)),
 81989002);

delete from user_sdo_geom_metadata where table_name='G_PONTAO';
insert into user_sdo_geom_metadata
(table_name, column_name, diminfo, srid)
values
('G_PONTAO', 'GEOM',
 SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 173618.078, 194805.785, .00000005), SDO_DIM_ELEMENT('Y', 1653028.55, 1683487.84, .00000005)),
 81989002);

delete from user_sdo_geom_metadata where table_name='G_VENTOSA';
insert into user_sdo_geom_metadata
(table_name, column_name, diminfo, srid)
values
('G_VENTOSA', 'GEOM',
 SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 173618.078, 194805.785, .00000005), SDO_DIM_ELEMENT('Y', 1653028.55, 1683487.84, .00000005)),
 81989002);
delete from user_sdo_geom_metadata where table_name='G_EST_BOMB_AGUA_BRUTA';
insert into user_sdo_geom_metadata
(table_name, column_name, diminfo, srid)
values
('G_EST_BOMB_AGUA_BRUTA', 'GEOM',
 SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 173618.078, 194805.785, .00000005), SDO_DIM_ELEMENT('Y', 1653028.55, 1683487.84, .00000005)),
 81989002);

delete from user_sdo_geom_metadata where table_name='G_EST_BOMB_AGUA_TRATADA';
insert into user_sdo_geom_metadata
(table_name, column_name, diminfo, srid)
values
('G_EST_BOMB_AGUA_TRATADA', 'GEOM',
 SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 173618.078, 194805.785, .00000005), SDO_DIM_ELEMENT('Y', 1653028.55, 1683487.84, .00000005)),
 81989002);

delete from user_sdo_geom_metadata where table_name='G_EST_TRAT_AGUA';
insert into user_sdo_geom_metadata
(table_name, column_name, diminfo, srid)
values
('G_EST_TRAT_AGUA', 'GEOM',
 SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 173618.078, 194805.785, .00000005), SDO_DIM_ELEMENT('Y', 1653028.55, 1683487.84, .00000005)),
 81989002);

delete from user_sdo_geom_metadata where table_name='G_QUADRAS';
insert into user_sdo_geom_metadata
(table_name, column_name, diminfo, srid)
values
('G_QUADRAS', 'GEOM',
 SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 173618.078, 194805.785, .00000005), SDO_DIM_ELEMENT('Y', 1653028.55, 1683487.84, .00000005)),
 81989002);

delete from user_sdo_geom_metadata where table_name='G_LOTES';
insert into user_sdo_geom_metadata
(table_name, column_name, diminfo, srid)
values
('G_LOTES', 'GEOM',
 SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 173618.078, 194805.785, .00000005), SDO_DIM_ELEMENT('Y', 1653028.55, 1683487.84, .00000005)),
 81989002);

delete from user_sdo_geom_metadata where table_name='G_EDIFICACAO';
insert into user_sdo_geom_metadata
(table_name, column_name, diminfo, srid)
values
('G_EDIFICACAO', 'GEOM',
 SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 173618.078, 194805.785, .00000005), SDO_DIM_ELEMENT('Y', 1653028.55, 1683487.84, .00000005)),
 81989002);

delete from user_sdo_geom_metadata where table_name='G_LOGRADOUROS';
insert into user_sdo_geom_metadata
(table_name, column_name, diminfo, srid)
values
('G_LOGRADOUROS', 'GEOM',
 SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 173618.078, 194805.785, .00000005), SDO_DIM_ELEMENT('Y', 1653028.55, 1683487.84, .00000005)),
 81989002);
--
delete from user_sdo_geom_metadata where table_name='G_VENTURI';
insert into user_sdo_geom_metadata
(table_name, column_name, diminfo, srid)
values
('G_VENTURI', 'GEOM',
 SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 173618.078, 194805.785, .00000005), SDO_DIM_ELEMENT('Y', 1653028.55, 1683487.84, .00000005)),
 81989002);

delete from user_sdo_geom_metadata where table_name='G_CONSUMIDORES';
insert into user_sdo_geom_metadata
(table_name, column_name, diminfo, srid)
values
('G_CONSUMIDORES', 'GEOM',
 SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 173618.078, 194805.785, .00000005), SDO_DIM_ELEMENT('Y', 1653028.55, 1683487.84, .00000005)),
 81989002);

delete from user_sdo_geom_metadata where table_name='G_REGISTRO';
insert into user_sdo_geom_metadata
(table_name, column_name, diminfo, srid)
values
('G_REGISTRO', 'GEOM',
 SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 173618.078, 194805.785, .00000005), SDO_DIM_ELEMENT('Y', 1653028.55, 1683487.84, .00000005)),
 81989002);

delete from user_sdo_geom_metadata where table_name='G_VALVULA_RETENCAO';
insert into user_sdo_geom_metadata
(table_name, column_name, diminfo, srid)
values
('G_VALVULA_RETENCAO', 'GEOM',
 SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 173618.078, 194805.785, .00000005), SDO_DIM_ELEMENT('Y', 1653028.55, 1683487.84, .00000005)),
 81989002);

delete from user_sdo_geom_metadata where table_name='G_REDE_ADUTORA';
insert into user_sdo_geom_metadata
(table_name, column_name, diminfo, srid)
values
('G_REDE_ADUTORA', 'GEOM',
 SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 173618.078, 194805.785, .00000005), SDO_DIM_ELEMENT('Y', 1653028.55, 1683487.84, .00000005)),
 81989002);

delete from user_sdo_geom_metadata where table_name='G_REDE_OUTROS';
insert into user_sdo_geom_metadata
(table_name, column_name, diminfo, srid)
values
('G_REDE_OUTROS', 'GEOM',
 SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 173618.078, 194805.785, .00000005), SDO_DIM_ELEMENT('Y', 1653028.55, 1683487.84, .00000005)),
 81989002);

delete from user_sdo_geom_metadata where table_name='G_REDE_RAMAL';
insert into user_sdo_geom_metadata
(table_name, column_name, diminfo, srid)
values
('G_REDE_RAMAL', 'GEOM',
 SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 173618.078, 194805.785, .00000005), SDO_DIM_ELEMENT('Y', 1653028.55, 1683487.84, .00000005)),
 81989002);

delete from user_sdo_geom_metadata where table_name='G_BYPASS';
insert into user_sdo_geom_metadata
(table_name, column_name, diminfo, srid)
values
('G_BYPASS', 'GEOM',
 SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 173618.078, 194805.785, .00000005), SDO_DIM_ELEMENT('Y', 1653028.55, 1683487.84, .00000005)),
 81989002);

delete from user_sdo_geom_metadata where table_name='G_HIDRANTE_SUBTERRANEO';
insert into user_sdo_geom_metadata
(table_name, column_name, diminfo, srid)
values
('G_HIDRANTE_SUBTERRANEO', 'GEOM',
 SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 173618.078, 194805.785, .00000005), SDO_DIM_ELEMENT('Y', 1653028.55, 1683487.84, .00000005)),
 81989002);

delete from user_sdo_geom_metadata where table_name='G_HIDROMETRO';
insert into user_sdo_geom_metadata
(table_name, column_name, diminfo, srid)
values
('G_HIDROMETRO', 'GEOM',
 SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 173618.078, 194805.785, .00000005), SDO_DIM_ELEMENT('Y', 1653028.55, 1683487.84, .00000005)),
 81989002);

delete from user_sdo_geom_metadata where table_name='G_POCO';
insert into user_sdo_geom_metadata
(table_name, column_name, diminfo, srid)
values
('G_POCO', 'GEOM',
 SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 173618.078, 194805.785, .00000005), SDO_DIM_ELEMENT('Y', 1653028.55, 1683487.84, .00000005)),
 81989002);

delete from user_sdo_geom_metadata where table_name='G_RESERVATORIO';
insert into user_sdo_geom_metadata
(table_name, column_name, diminfo, srid)
values
('G_RESERVATORIO', 'GEOM',
 SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 173618.078, 194805.785, .00000005), SDO_DIM_ELEMENT('Y', 1653028.55, 1683487.84, .00000005)),
 81989002);

delete from user_sdo_geom_metadata where table_name='G_VALVULA_ANTIGOLPE';
insert into user_sdo_geom_metadata
(table_name, column_name, diminfo, srid)
values
('G_VALVULA_ANTIGOLPE', 'GEOM',
 SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 173618.078, 194805.785, .00000005), SDO_DIM_ELEMENT('Y', 1653028.55, 1683487.84, .00000005)),
 81989002);

delete from user_sdo_geom_metadata where table_name='G_VALVULA_BORBOLETA';
insert into user_sdo_geom_metadata
(table_name, column_name, diminfo, srid)
values
('G_VALVULA_BORBOLETA', 'GEOM',
 SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 173618.078, 194805.785, .00000005), SDO_DIM_ELEMENT('Y', 1653028.55, 1683487.84, .00000005)),
 81989002);

delete from user_sdo_geom_metadata where table_name='G_VALVULA_REDUT_PRESSAO';
insert into user_sdo_geom_metadata
(table_name, column_name, diminfo, srid)
values
('G_VALVULA_REDUT_PRESSAO', 'GEOM',
 SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 173618.078, 194805.785, .00000005), SDO_DIM_ELEMENT('Y', 1653028.55, 1683487.84, .00000005)),
 81989002);

delete from user_sdo_geom_metadata where table_name='G_HIDRANTE_COLUNA';
insert into user_sdo_geom_metadata
(table_name, column_name, diminfo, srid)
values
('G_HIDRANTE_COLUNA', 'GEOM',
 SDO_DIM_ARRAY(SDO_DIM_ELEMENT('X', 173618.078, 194805.785, .00000005), SDO_DIM_ELEMENT('Y', 1653028.55, 1683487.84, .00000005)),
 81989002);

-- Create indexes for node and link tables
create index node_id_idx on daee_node$(node_id);
create index node_geom_idx on daee_node$(geometry) indextype is mdsys.spatial_index;
create index link_id_idx on daee_link$(link_id);
create index link_geom_idx on daee_link$(geometry) indextype is mdsys.spatial_index;
create index l_sid_eid_idx on daee_link$(start_node_id, end_node_id);

-- Create indexes for component tables; this is for mapping purpose.
create index cap_geom_idx on G_CAP(geom) indextype is mdsys.spatial_index;
create index cur_geom_idx on G_CURVA(geom) indextype is mdsys.spatial_index;
create index cur11_geom_idx on G_CURVA_11(geom) indextype is mdsys.spatial_index;
create index cur22_geom_idx on G_CURVA_22(geom) indextype is mdsys.spatial_index;
create index cur30_geom_idx on G_CURVA_30(geom) indextype is mdsys.spatial_index;
create index cur45_geom_idx on G_CURVA_45(geom) indextype is mdsys.spatial_index;
create index cur90_geom_idx on G_CURVA_90(geom) indextype is mdsys.spatial_index;
create index cruz_geom_idx on G_CRUZETA(geom) indextype is mdsys.spatial_index;
create index redc_geom_idx on G_REDUCAO(geom) indextype is mdsys.spatial_index;
create index te_geom_idx on G_TE(geom) indextype is mdsys.spatial_index;
create index luva_geom_idx on G_LUVA(geom) indextype is mdsys.spatial_index;
create index tap_geom_idx on G_TAP(geom) indextype is mdsys.spatial_index;
create index adap_geom_idx on G_ADAPTADOR(geom) indextype is mdsys.spatial_index;
create index embu_geom_idx on G_EMBUTIDO(geom) indextype is mdsys.spatial_index;
create index ferr_geom_idx on G_FERRULE(geom) indextype is mdsys.spatial_index;
create index flan_geom_idx on G_FLANGE(geom) indextype is mdsys.spatial_index;
create index pon_geom_idx on G_PONTAO(geom) indextype is mdsys.spatial_index;
create index vent_geom_idx on G_VENTOSA(geom) indextype is mdsys.spatial_index;
create index brut_geom_idx on G_EST_BOMB_AGUA_BRUTA(geom) indextype is mdsys.spatial_index;
create index trat_geom_idx on G_EST_BOMB_AGUA_TRATADA(geom) indextype is mdsys.spatial_index;
create index agua_geom_idx on G_EST_TRAT_AGUA(geom) indextype is mdsys.spatial_index;
create index quad_geom_idx on G_QUADRAS(geom) indextype is mdsys.spatial_index;
create index lotes_geom_idx on G_LOTES(geom) indextype is mdsys.spatial_index;
create index edif_geom_idx on G_EDIFICACAO(geom) indextype is mdsys.spatial_index;
create index logra_geom_idx on G_LOGRADOUROS(geom) indextype is mdsys.spatial_index;
create index ventu_geom_idx on G_VENTURI(geom) indextype is mdsys.spatial_index;
create index consu_geom_idx on G_CONSUMIDORES(geom) indextype is mdsys.spatial_index;
create index regis_geom_idx on G_REGISTRO(geom) indextype is mdsys.spatial_index;
create index valret_geom_idx on G_VALVULA_RETENCAO(geom) indextype is mdsys.spatial_index;
create index rede_adu_geom_idx on G_REDE_ADUTORA(geom) indextype is mdsys.spatial_index;
create index rede_out_geom_idx on G_REDE_OUTROS(geom) indextype is mdsys.spatial_index;
create index rede_ram_geom_idx on G_REDE_RAMAL(geom) indextype is mdsys.spatial_index;
create index bypass_geom_idx on G_BYPASS(geom) indextype is mdsys.spatial_index;
create index hidr_s_geom_idx on G_HIDRANTE_SUBTERRANEO(geom) indextype is mdsys.spatial_index;
create index hidrm_geom_idx on G_HIDROMETRO(geom) indextype is mdsys.spatial_index;
create index poco_geom_idx on G_POCO(geom) indextype is mdsys.spatial_index;
create index resr_geom_idx on G_RESERVATORIO(geom) indextype is mdsys.spatial_index;
create index valag_geom_idx on G_VALVULA_ANTIGOLPE(geom) indextype is mdsys.spatial_index;
create index valbor_geom_idx on G_VALVULA_BORBOLETA(geom) indextype is mdsys.spatial_index;
create index valpres_geom_idx on G_VALVULA_REDUT_PRESSAO(geom) indextype is mdsys.spatial_index;
create index hidr_col_geom_idx on G_HIDRANTE_COLUNA(geom) indextype is mdsys.spatial_index;

