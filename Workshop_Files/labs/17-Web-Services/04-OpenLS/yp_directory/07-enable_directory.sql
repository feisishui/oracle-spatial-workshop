-- Run as SYSTEM

-- Drop pre-created directory tables
drop table mdsys.OLS_DIR_CATEGORIZATIONS;
drop table mdsys.OLS_DIR_BUSINESSES;
drop table mdsys.OLS_DIR_BUSINESS_CHAINS;
drop table mdsys.OLS_DIR_CATEGORIES;
drop table mdsys.OLS_DIR_CATEGORY_TYPES;
drop table mdsys.OLS_DIR_SYNONYMS;

-- Create synonyms for directory tables
create or replace synonym mdsys.OLS_DIR_CATEGORIZATIONS
  for scott.OLS_DIR_CATEGORIZATIONS;
create or replace synonym mdsys.OLS_DIR_BUSINESSES
  for scott.OLS_DIR_BUSINESSES;
create or replace synonym mdsys.OLS_DIR_BUSINESS_CHAINS
  for scott.OLS_DIR_BUSINESS_CHAINS;
create or replace synonym mdsys.OLS_DIR_CATEGORIES
  for scott.OLS_DIR_CATEGORIES;
create or replace synonym mdsys.OLS_DIR_CATEGORY_TYPES
  for scott.OLS_DIR_CATEGORY_TYPES;
create or replace synonym mdsys.OLS_DIR_SYNONYMS
  for scott.OLS_DIR_SYNONYMS;

-- Grant access to the directory tables
grant select on scott.OLS_DIR_CATEGORIZATIONS      to OLS_USR_ROLE;
grant select on scott.OLS_DIR_BUSINESSES           to OLS_USR_ROLE;
grant select on scott.OLS_DIR_BUSINESS_CHAINS      to OLS_USR_ROLE;
grant select on scott.OLS_DIR_CATEGORIES           to OLS_USR_ROLE;
grant select on scott.OLS_DIR_CATEGORY_TYPES       to OLS_USR_ROLE;
grant select on scott.OLS_DIR_SYNONYMS             to OLS_USR_ROLE;
