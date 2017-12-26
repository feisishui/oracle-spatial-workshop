/*

  Populate the business chains table

  The chain table is loaded with a set of popular brand names.
  Businesses are assumed to be part of the chain if their
  name contains the name of the chain.

  Note that some businesses could match multiple chains (like "Hertz Marriott").
  In those cases, just the first match is used.

*/

-- Then populate the chain table
insert into ols_dir_business_chains (chain_id, chain_name) values (  1,    'Hilton');
insert into ols_dir_business_chains (chain_id, chain_name) values (  2,    'Sheraton');
insert into ols_dir_business_chains (chain_id, chain_name) values (  3,    'Marriott');
insert into ols_dir_business_chains (chain_id, chain_name) values (  4,    'Meridien');
insert into ols_dir_business_chains (chain_id, chain_name) values (  5,    'Mercure');
insert into ols_dir_business_chains (chain_id, chain_name) values (  6,    'Starbucks');
insert into ols_dir_business_chains (chain_id, chain_name) values (  7,    'Shell');
insert into ols_dir_business_chains (chain_id, chain_name) values (  8,    'Avis');
insert into ols_dir_business_chains (chain_id, chain_name) values (  9,    'Hertz');
insert into ols_dir_business_chains (chain_id, chain_name) values ( 10,    'Burger King');
insert into ols_dir_business_chains (chain_id, chain_name) values ( 11,    'McDonald');
insert into ols_dir_business_chains (chain_id, chain_name) values ( 12,    'Wells Fargo');
insert into ols_dir_business_chains (chain_id, chain_name) values ( 13,    'Bank of America');
insert into ols_dir_business_chains (chain_id, chain_name) values ( 14,    'Wells Fargo');
insert into ols_dir_business_chains (chain_id, chain_name) values ( 15,    'Wells Fargo');

-- Now, populate the chain ids
update ols_dir_businesses
set chain_id = (
  select chain_id
  from ols_dir_business_chains
  where business_name like '%'|| upper(chain_name) ||'%'
  and rownum = 1
);
commit;

-- View the results
col chain_name for a40
select c.chain_id, c.chain_name, count(*)
from ols_dir_business_chains c, ols_dir_businesses b
where c.chain_id = b.chain_id
group by c.chain_id, c.chain_name
order by c.chain_id;
