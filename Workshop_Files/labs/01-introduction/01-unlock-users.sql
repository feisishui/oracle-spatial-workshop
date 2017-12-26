-- Connect as SYSTEM
connect system

-- Unlock user SCOTT
alter user scott account unlock;
alter user scott identified by tiger;

-- Unlock user MDSYS
alter user mdsys account unlock;
alter user mdsys identified by mdsys;
