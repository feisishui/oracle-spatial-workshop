/*

  Populate the categorization table based on the feature code
  (stored in the "description" column)

*/

insert into ols_dir_categorizations (business_id, category_id, category_type_id)
  select business_id, description, 1
  from ols_dir_businesses;

commit;

-- Show results
col category_name for a30
col category_id   for a10
select  c.category_id, c.category_name, count(*)
from    ols_dir_businesses b, ols_dir_categorizations bc, ols_dir_categories c
where   b.business_id = bc.business_id
and     c.category_id = bc.category_id
group by c.category_id, c.category_name
order by c.category_id;
