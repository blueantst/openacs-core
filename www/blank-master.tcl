# /www/master-default.tcl
#
# Set basic attributes and provide the logical defaults for variables that
# aren't provided by the slave page.
#
# Author: Kevin Scaldeferri (kevin@arsdigita.com)
# Creation Date: 14 Sept 2000
# $Id$
#

# fall back on defaults

if { [template::util::is_nil doc_type] } { 
    set doc_type {<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">}
}

if { [template::util::is_nil title] } { 
    set title [ad_conn instance_name]  
}

if { ![info exists header_stuff] } {
    set header_stuff {} 
}


# Attributes

multirow create attribute key value

set onload {}

if { ![template::util::is_nil focus] } {
    # Handle elements wohse name contains a dot
    if { [regexp {^([^.]*)\.(.*)$} $focus match form_name element_name] } {
        lappend onload "acs_Focus('${form_name}', '${element_name}');"
    }
}

multirow append attribute onload [join $onload " "]

# Header links (stylesheets, javascript)
multirow create header_links rel type href media
multirow append header_links "stylesheet" "text/css" "/resources/acs-templating/lists.css" "all"
multirow append header_links "stylesheet" "text/css" "/resources/acs-templating/forms.css" "all"
multirow append header_links "stylesheet" "text/css" "/resources/acs-subsite/default-master.css" "all"

# Developer-support: We include that here, so that master template authors don't have to worry about it

if { [llength [namespace eval :: info procs ds_show_p]] == 1 } {
    set developer_support_p 1
} else {
    set developer_support_p 0
}

set translator_mode_p [lang::util::translator_mode_p]

set openacs_version [ad_acs_version]

# Toggle translator mode link

set acs_lang_url [apm_package_url_from_key "acs-lang"]
if { [empty_string_p $acs_lang_url] } {
    set lang_admin_p 0
} else {
    set lang_admin_p [permission::permission_p \
                          -object_id [site_node::get_element -url $acs_lang_url -element object_id] \
                          -privilege admin \
                          -party_id [ad_conn untrusted_user_id]]
}
set toggle_translator_mode_url [export_vars -base "${acs_lang_url}admin/translator-mode-toggle" { { return_url [ad_return_url] } }]

