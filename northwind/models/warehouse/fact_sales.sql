with source as (
    select * from {{ ref('stg_orders') }} o
    left join {{ ref('stg_order_details') }} od
    on o.order_id = od.id
    where od.order_id is not null
),
unique_source as (
    select *, row_number() over(partition by customer_id, employee_id, order_id, product_id, shipper_id, purchase_order_id, shipper) as row_number from source
)