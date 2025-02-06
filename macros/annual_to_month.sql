{% macro annual_to_month(val) -%}
    ( cast({{ val }} as numeric)/12 )
{%- endmacro %}