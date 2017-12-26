-- Find all tables registered for use in WFS transactions
select owner, table_name
from (
  select owner, table_name
  from all_triggers
  where trigger_name = table_name || '_UL'
  and trigger_type = 'AFTER EACH ROW'
  and triggering_event = 'UPDATE'
  union all
  select owner, table_name
  from all_triggers
  where trigger_name = table_name || '_DL'
  and trigger_type = 'AFTER EACH ROW'
  and triggering_event = 'DELETE'
  union all
  select owner, table_name
  from all_triggers
  where trigger_name = table_name || '_CUL'
  and trigger_type = 'BEFORE EACH ROW'
  and triggering_event = 'UPDATE'
  union all
  select owner, table_name
  from all_triggers
  where trigger_name = table_name || '_CDL'
  and trigger_type = 'BEFORE EACH ROW'
  and triggering_event = 'DELETE'
)
group by owner, table_name
having count(*) = 4;