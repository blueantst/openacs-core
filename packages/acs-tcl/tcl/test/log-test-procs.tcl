ad_library {
    Examine error logs

    @author Lars Pind (lars@collaboraid.biz)
    @creation-date 22 January 2003
}

aa_register_case server_error_log {
    Examine server error log.
} {
    # Log error lines start with something like this:
    # [19/Nov/2003:00:54:45][10491.319494][-conn1-] Error: 
    
    catch { exec grep {^[^ ]* Error: } /web/lars/log/error.log } errors

    set logfile [ns_info log]

    if { [string equal $logfile "STDOUT"] } {
        set logfile "[acs_root_dir]/log/error/current"
    }

    set fd [open $logfile r]
    
    set entry {}
    set inside_error_p 0

    while { [gets $fd line] != -1 } {
        if { [regexp {^\[([^\]]*)\]\[[^\]]*\]\[[^\]]*\] ([^: ]*): (.*)$} $line match timestamp level rest] } {
            if { $inside_error_p } {
                aa_log_result "fail" "$timestamp: $entry"
                set inside_error_p 0
            }
            if { [string equal $level "Error"] } {
                set inside_error_p 1
                set entry {}
                append entry $rest \n
                #"(Rest was=$rest)" \n
            }
        } elseif { $inside_error_p } {
            append entry $line \n
        }
    }
}

