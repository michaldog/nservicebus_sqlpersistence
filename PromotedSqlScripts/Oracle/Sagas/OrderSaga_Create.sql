
/* TableNameVariable */

/* Initialize */

declare
  sqlStatement varchar2(500);
  dataType varchar2(30);
  n number(10);
  currentSchema varchar2(500);
begin
select sys_context('USERENV','CURRENT_SCHEMA') into currentSchema from dual;


/* CreateTable */

  select count(*) into n from user_tables where table_name = 'ORDERSAGA';
  if(n = 0)
  then

    sqlStatement :=
       'create table "ORDERSAGA"
       (
          id varchar2(38) not null,
          metadata clob not null,
          data clob not null,
          persistenceversion varchar2(23) not null,
          sagatypeversion varchar2(23) not null,
          concurrency number(9) not null,
          constraint "ORDERSAGA_PK" primary key
          (
            id
          )
          enable
        )';

    execute immediate sqlStatement;

  end if;

/* AddProperty OrderId */

select count(*) into n from all_tab_columns where table_name = 'ORDERSAGA' and column_name = 'CORR_ORDERID' and owner = currentSchema;
if(n = 0)
then
  sqlStatement := 'alter table "ORDERSAGA" add ( CORR_ORDERID VARCHAR2(38) )';

  execute immediate sqlStatement;
end if;

/* VerifyColumnType Guid */

select data_type ||
  case when char_length > 0 then
    '(' || char_length || ')'
  else
    case when data_precision is not null then
      '(' || data_precision ||
        case when data_scale is not null and data_scale > 0 then
          ',' || data_scale
        end || ')'
    end
  end into dataType
from all_tab_columns
where table_name = 'ORDERSAGA' and column_name = 'CORR_ORDERID' and owner = currentSchema;

if(dataType <> 'VARCHAR2(38)')
then
  raise_application_error(-20000, 'Incorrect data type for Correlation_CORR_ORDERID.  Expected "VARCHAR2(38)" got "' || dataType || '".');
end if;

/* WriteCreateIndex OrderId */

select count(*) into n from user_indexes where table_name = 'ORDERSAGA' and index_name = 'SAGAIDX_FD8BAD844CFBBE419E43FE';
if(n = 0)
then
  sqlStatement := 'create unique index "SAGAIDX_FD8BAD844CFBBE419E43FE" on "ORDERSAGA" (CORR_ORDERID ASC)';

  execute immediate sqlStatement;
end if;

/* PurgeObsoleteIndex */

/* PurgeObsoleteProperties */

select count(*) into n
from all_tab_columns
where table_name = 'ORDERSAGA' and column_name like 'CORR_%' and
        column_name <> 'CORR_ORDERID' and owner = currentSchema;

if(n > 0)
then

  select 'alter table "ORDERSAGA" drop column ' || column_name into sqlStatement
  from all_tab_columns
  where table_name = 'ORDERSAGA' and column_name like 'CORR_%' and
        column_name <> 'CORR_ORDERID' and owner = currentSchema;

  execute immediate sqlStatement;

end if;

/* CompleteSagaScript */
end;
