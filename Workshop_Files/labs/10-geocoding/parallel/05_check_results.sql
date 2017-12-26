col accuracy for a30
col pct for 90.9
with p as (
  select gc_accuracy_string(gc_accuracy(gc_result)) accuracy, count(*) num
  from gc_results 
  group by gc_accuracy_string(gc_accuracy(gc_result))
)
select accuracy, num,
       cast(ratio_to_report(num) over () * 100 as number(5,1)) as pct
from p
order by accuracy;
