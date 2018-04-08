#!/bin/bash
# tablespace usagep check
source ~/.bash_profile
rm -rf /tmp/{ora_tablespace.txt,ora_autex.txt}
function check {
sqlplus -S "/ as sysdba" <<  EOF
set linesize 100
set pagesize 100
spool /tmp/ora_tablespace.txt
select a.tablespace_name, total, free,(total-free) as usage from 
(select tablespace_name, sum(bytes)/1024/1024 as total from dba_data_files group by tablespace_name) a, 
(select tablespace_name, sum(bytes)/1024/1024 as free from dba_free_space group by tablespace_name) b
where a.tablespace_name = b.tablespace_name;
spool off

set linesize 100
set pagesize 100
spool /tmp/ora_autex.txt
select tablespace_name,autoextensible from dba_data_files;
spool off
quit
EOF
};check &>/dev/null
