<html>
<head>
<title>AOLserver Telemetry</title>
<STYLE>
    BODY { background: #ffffff; font-family: helvetica; font-size: 10pt; }
    H1   { font-family: helvetica; font-size: 18pt; }
    H2   { font-family: helvetica; font-size: 16pt; }
    H3   { font-family: helvetica; font-size: 14pt; }
    TD   { background: cyan; font-family: helvetica; font-size: 10pt; }
    PRE  { font-family: helvetica; font-size: 10pt; }
    FORM { font-family: helvetica; font-size: 8pt; }
</STYLE>
</head>

<body>
<h2>AOLserver Telemetry</h2>

<h3>Server Information</h3>

<blockquote>

<table>
<%

## Server information.
## Things that don't go here: threads, callbacks, scheduled, sockcallbacks
foreach item {
    server hostname address
    pid uptime boottime
    home config log pageroot tcllib
    nsd argv0 name version label builddate platform
} {
    ## Note the catch so this works on all AOLserver revisions.
    if [catch {
	set itemval [ns_info $item]
	if [regexp {boottime} $item] {
	    set itemval "[ns_httptime $itemval]"
	}
	ns_puts "<tr>
<td align=right valign=top><b>$item:</b></td>
<td align=left valign=top>$itemval &nbsp;</td>
</tr>"
    } errMsg] {
	## Catch commands that don't exist.
	ns_puts "<tr>
<td align=right><b>$item:</b></td><td align=left>n/a</td>
</tr>"
	continue
    }
}
%>

</table>

</blockquote>


<h3>Memory Cache</h3>

<blockquote>

<table>
<tr>
<td align=left valign=top><b>name</b></td>
<td align=left valign=top><b>stats</b></td>
</tr>
<%

foreach item [lsort [ns_cache_names]] {
    ns_puts "<tr><td align=left valign=top>$item</td>"
    ns_puts "<td align=left valign=top>[ns_cache_stats $item]&nbsp;</td></tr>"
}
%>
</table>
</blockquote>

<h3>NSV arrays</h3>
<blockquote>
<table>
<tr>
<td align=left valign=top><b>name</b></td>
<td align=left valign=top><b>entries</b></td>
<td align=left valign=top><b>bytes</b></td>
</tr>
<%
foreach key [lsort [nsv_names]] {
      ns_puts "<tr><td>$key</td><td>[nsv_array size $key]</td><td align=right>[string bytelength [nsv_array get $key]]</td></tr>\n"
}
%>
</table>
</blockquote>


<h3>Thread Locks</h3>

<blockquote>

<table>

<tr>
<td align=left valign=top><b>name</b></td>
<td align=left valign=top><b>owner</b></td>
<td align=left valign=top><b>id</b></td>
<td align=left valign=top><b>nlock</b></td>
<td align=left valign=top><b>nbusy</b></td>
</tr>

<%
foreach item [lsort [ns_info locks]] {
    ns_puts "<tr>"
    ns_puts "<td align=left valign=top>[lindex $item 0]&nbsp;</td>"
    for { set i 1 } { $i < [llength $item] } { incr i } {
	ns_puts "<td align=right valign=top>&nbsp;[lindex $item $i]</td>"
    }
    ns_puts "</tr>"
}
%>

</table>

</blockquote>

<h3>Running Threads</h3>

<blockquote>

<table>

<tr>
<td align=left valign=top><b>name</b></td>
<td align=left valign=top><b>parent</b></td>
<td align=left valign=top><b>tid</b></td>
<td align=left valign=top><b>flags</b></td>
<td align=left valign=top><b>ctime</b></td>
<td align=left valign=top><b>proc</b></td>
<td align=left valign=top><b>arg</b></td>
</tr>


<%
foreach item [lsort [ns_info threads]] {
    ns_puts "<tr>"
    for { set i 0 } { $i < 7 } { incr i } {
	ns_puts "<td align=left valign=top><pre>"
	if { $i != 4 } {
	    ns_puts "[lindex $item $i]"
	} else {
	    ns_puts "[ns_httptime [lindex $item $i]]"
	}
	ns_puts "</pre></td>"
    }
    ns_puts "</tr>"
}
%>

</table>

</blockquote>

<h3>Scheduled Procedures</h3>

<blockquote>

<table>

<tr>
<td align=left valign=bottom><b>proc</b></td>
<td align=left valign=bottom><b>id</b></td>
<td align=left valign=bottom><b>flags</b></td>
<td align=left valign=bottom><b>interval</b></td>
<td align=left valign=bottom><b>nextqueue<br>lastqueue<br>laststart<br>lastend<br></b></td>
<td align=left valign=bottom><b>arg</b></td>
</tr>


<%
foreach item [lsort [ns_info scheduled]] {
    ns_puts "<tr>"

    ## proc, id, flags, interval
    ns_puts "<td align=left valign=top>[lindex $item 7]&nbsp;</td>"

    for { set i 0 } { $i < 3 } { incr i } {
	ns_puts "<td align=left valign=top>[lindex $item $i]&nbsp;</td>"
    }

    ## times: nextqueue, lastqueue, laststart, lastend
    ns_puts "<td align=left valign=top><pre>"
    for { set i 3 } { $i < 7 } { incr i } {
	ns_puts "[ns_httptime [lindex $item $i]]"
    }
    ns_puts "</pre></td>"

    ## arg
    ns_puts "<td align=left valign=top>[lindex $item 8]&nbsp;</td>"

    ns_puts "</tr>"
}
%>

</table>

</blockquote>

<h3>Connections (web clients)</h3>

<blockquote>

<table>

<%
foreach item {
    connections waiting queued keepalive
} {
    ns_puts "<tr><td align=left valign=top><b>$item:</b></td>"
    ns_puts "<td align=right valign=top>&nbsp;[ns_server $item]</td></tr>"
}

%>

</table>

</blockquote>


<h3>Callbacks -- Events</h3>

<blockquote>

<table>

<tr>
<td align=left valign=top><b>event</b></td>
<td align=left valign=top><b>name</b></td>
<td align=left valign=top><b>arg</b></td>
</tr>

<%
foreach item [lsort [ns_info callbacks]] {
    ns_puts "<tr>"
    for { set i 0 } { $i < 3 } { incr i } {
	ns_puts "<td align=left valign=top>[lindex $item $i]&nbsp;</td>"
    }
    ns_puts "</tr>"
}
%>

</table>

</blockquote>

<h3>Callbacks -- Sockets (sockcallbacks)</h3>

<blockquote>

<table>

<tr>
<td align=left valign=top><b>sock id</b></td>
<td align=left valign=top><b>when</b></td>
<td align=left valign=top><b>proc</b></td>
<td align=left valign=top><b>arg</b></td>
</tr>

<%
foreach item [lsort [ns_info sockcallbacks]] {
    ns_puts "<tr>"
    for { set i 0 } { $i < 4 } { incr i } {
	ns_puts "<td align=left valign=top>[lindex $item $i]</td>"
    }
    ns_puts "</tr>"
}
%>

</table>

</blockquote>


<h3>URL Stats</h3>

<blockquote>

<table>

<tr>
<td align=left valign=top><b>url</b></td>
<td align=right valign=top><b>hits</b></td>
<td align=right valign=top><b>wait (sec)</b></td>
<td align=right valign=top><b>open (sec)</b></td>
<td align=right valign=top><b>closed (sec)</b></td>
</tr>

<%
foreach item [lsort [ns_server urlstats]] {
   set N [lindex [lindex $item 1] 0]
    ns_puts "<tr>"
    ns_puts "<td align=left valign=top><a href=\"[lindex $item 0]\">[lindex $item 0]<a/>&nbsp;</td>"
    ns_puts "<td align=right valign=top>&nbsp;$N</td>"

    foreach {sec usec} [lrange [lindex $item 1] 1 7] { 
	    ns_puts "<td align=right valign=top>[format "%6f" [expr {($sec + ($usec * .000001))/$N}]]</td>"
    }
    ns_puts "</tr>"
}
%>
</table>

</blockquote>

<h3>Tcl Information -- Tcl Core</h3>

<blockquote>
<table>

<%
## Tcl library information.

foreach item {
    tclversion patchlevel level
    nameofexecutable sharedlibextension library} {
    ns_puts "<tr><td align=right valign=top><b>$item:</b></td>"
    ns_puts "<td align=left>[info $item]</td></tr>"
}
%>
</table>
</blockquote>


<h3>HTTP Headers</h3>

<blockquote>
<pre>
<%
for { set i 0 } { $i < [ns_set size [ns_conn headers]] } { incr i } {
    ns_puts "[ns_set key [ns_conn headers] $i]: [ns_set \
                value [ns_conn headers] $i]"
}
%>
</pre>
</blockquote>

<h3>util_memoize cache info</h3>

<%
if {0} {
   foreach name [ns_cache names util_memoize] {
      ns_puts "$name size = [ns_cache get util_memoize $name]<br>"
   }
}
%>

<% ns_puts [info commands] %>
        
</body>
</html>

