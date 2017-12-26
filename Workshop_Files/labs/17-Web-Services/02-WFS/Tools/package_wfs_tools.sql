create or replace package wfs_tools authid current_user is

-------------------------------------------------------------------------------
-- set_anonymous_user
-------------------------------------------------------------------------------
procedure set_anonymous_user (
  p_anonymous_user    varchar2
);

-------------------------------------------------------------------------------
-- set_namespace
-------------------------------------------------------------------------------
procedure set_namespace (
  p_namespace_url     varchar2,
  p_namespace_alias   varchar2
);

-------------------------------------------------------------------------------
-- publish_table
-------------------------------------------------------------------------------
procedure publish_table (
  p_owner               varchar2,
  p_table_name          varchar2,
  p_updatable           varchar2 := 'FALSE',
  p_geometry_column     varchar2 := NULL,
  p_feature_name        varchar2 := NULL,
  p_feature_desc        varchar2 := NULL,
  p_namespace_url       varchar2 := NULL,
  p_namespace_alias     varchar2 := NULL
);

-------------------------------------------------------------------------------
-- publish_schema
-------------------------------------------------------------------------------
procedure publish_schema (
  p_owner               varchar2,
  p_updatable           varchar2 := 'FALSE',
  p_namespace_url       varchar2 := NULL,
  p_namespace_alias     varchar2 := NULL
);

-------------------------------------------------------------------------------
-- unpublish_table
-------------------------------------------------------------------------------
procedure unpublish_table (
  p_owner               varchar2,
  p_table_name          varchar2
);

-------------------------------------------------------------------------------
-- unpublish_schema
-------------------------------------------------------------------------------
procedure unpublish_schema (
  p_owner               varchar2
);

-------------------------------------------------------------------------------
-- is_published
-------------------------------------------------------------------------------
function is_published (
  p_owner               varchar2,
  p_table_name          varchar2
)
return varchar2;

-------------------------------------------------------------------------------
-- is_registered_for_updates
-------------------------------------------------------------------------------
function is_registered_for_updates (
  p_owner               varchar2,
  p_table_name          varchar2
)
return varchar2;

end;
/
show errors
grant execute on wfs_tools to public;
