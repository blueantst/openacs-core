<div class="@list_properties.class@">
<noparse>
  <if \@@list_properties.multirow@:rowcount@ eq 0>
</noparse>
    @list_properties.no_data@
<noparse>
  </if>
  <else>
</noparse>
  <if @bulk_actions:rowcount@ gt 0>
    <form name="@list_properties.name@" method="@list_properties.bulk_action_method@">
    @list_properties.bulk_action_export_chunk;noquote@
  </if>

  <if @actions:rowcount@ gt 0>
    <div class="list-button-bar">
      <multiple name="actions">
        <span class="list-button-header"><a href="@actions.url@" class="list-button" title="@actions.title@">@actions.label@</a></span>
      </multiple>
    </div>
  </if>

    <noparse>
      <multiple name="@list_properties.multirow@">
      <if \@@list_properties.multirow@.rownum@ odd>
         <div class="list-row odd">
      </if><else>
         <div class="list-row even">
      </else>
    </noparse>

        <listrow>
      </div>

    <noparse>
      </multiple>
    </noparse>

  <if @bulk_actions:rowcount@ gt 0>
    <div class="list-button-bar">
      <multiple name="bulk_actions">
        <span class="list-button-header"><a href="#" class="list-button" title="@bulk_actions.title@" 
        onclick="ListBulkActionClick('@list_properties.name@', '@bulk_actions.url@')">@bulk_actions.label@</a></span>
      </multiple>
    </div>
    </form>
  </if>



<noparse>
  </else>
</noparse>
</div>
