<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="lc_time_utc_to_local.utc_to_local">      
      <querytext>
      
	    begin
	    :1 := to_char(timezone.utc_to_local(:tz, to_date(:time_value, 'YYYY-MM-DD HH24:MI:SS')), 'YYYY-MM-DD HH24:MI:SS');
	    end;
	
      </querytext>
</fullquery>

 
<fullquery name="lc_time_local_to_utc.local_to_utc">      
      <querytext>
      
	    begin
	    :1 := to_char(timezone.local_to_utc(:tz, to_date(:time_value, 'YYYY-MM-DD HH24:MI:SS')), 'YYYY-MM-DD HH24:MI:SS');
	    end;
	
      </querytext>
</fullquery>

 
</queryset>
