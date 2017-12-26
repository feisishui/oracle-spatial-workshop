col tokenid for a8
col lockid for a8
col tablename for a20
col sessionid for a12
col expirytime for a30

-- Active locks
select t.sessionid, t.tokenid lockid, t.expirytime, t.expirytime - current_timestamp duration_left, count(*) numrows
from   mdsys.tokensessionmap_t$ t,
       mdsys.rowtokenmap_t$ r
where  t.expirytime >= current_timestamp
and    t.tokenid = r.tokenid
group by t.sessionid, t.tokenid, t.expirytime;

-- Locked rows summary
select t.tokenid lockid, t.expirytime, r.tablename, count(*) numrows
from   mdsys.tokensessionmap_t$ t,
       mdsys.rowtokenmap_t$ r
where  t.expirytime >= current_timestamp
and    t.tokenid = r.tokenid
group by t.tokenid, t.expirytime, r.tablename;

-- Locked rows details
select t.tokenid lockid, t.expirytime, r.tablename, r.rowid
from   mdsys.tokensessionmap_t$ t,
       mdsys.rowtokenmap_t$ r
where  t.expirytime >= current_timestamp
and    t.tokenid = r.tokenid
order by t.tokenid, t.expirytime, r.tablename;
