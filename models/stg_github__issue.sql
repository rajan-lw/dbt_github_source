with issue as (

    select *
    from {{ ref('stg_github__issue_tmp') }}

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
                source_columns=adapter.get_columns_in_relation(ref('stg_github__issue_tmp')),
                staging_columns=get_issue_columns()
            )
        }}

        --The below script allows for pass through columns.
        {% if var('issue_pass_through_columns') %}
        ,
        {{ var('issue_pass_through_columns') | join (", ")}}

        {% endif %}
    from issue 

), fields as (

    select 
      id as issue_id,
      body,
      closed_at,
      created_at,
      locked as is_locked,
      milestone_id,
      number as issue_number,
      pull_request as is_pull_request,
      repository_id,
      state,
      title,
      updated_at,
      user_id

      --The below script allows for pass through columns.
      {% if var('issue_pass_through_columns') %}
      ,
      {{ var('issue_pass_through_columns') | join (", ")}}

      {% endif %}
      
    from macro
)

select *
from fields