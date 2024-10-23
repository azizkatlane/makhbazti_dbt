{% macro total_amount(up, q) %}
    ({{ up }} * {{ q }})::numeric(10,2)
{% endmacro %}
