with github_user as (

    select *
    from {{ ref('stg_github__user_tmp') }}

), macro as (
    select
        /*
        The below macro is used to generate the correct SQL for package staging models. It takes a list of columns 
        that are expected/needed (staging_columns from dbt_github_source/models/tmp/) and compares it with columns 
        in the source (source_columns from dbt_github_source/macros/).

        For more information refer to our dbt_fivetran_utils documentation (https://github.com/fivetran/dbt_fivetran_utils.git).
        */
            {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_github__user_tmp')),
                staging_columns=get_user_columns()
            )
        }}

        --The below script allows for pass through columns.
        {% if var('user_pass_through_columns') %}
        ,
        {{ var('user_pass_through_columns') | join (", ")}}

        {% endif %}
    from github_user

), fields as (

    select
      id as user_id,
      login as login_name,
      name,
      bio,
      company

      --The below script allows for pass through columns.
      {% if var('user_pass_through_columns') %}
      ,
      {{ var('user_pass_through_columns') | join (", ")}}

      {% endif %}

    from macro
)

select *
from fields