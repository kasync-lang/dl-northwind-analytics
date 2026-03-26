
    with source as (
        select * from {{ source('northwind','sales_reports') }}
    )
   select *, current_timestamp() as ingestion_timestamp
from source
    