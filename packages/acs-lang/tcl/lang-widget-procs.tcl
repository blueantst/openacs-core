ad_library {

    Widgets for acs-lang.

    Currently just a special version of the select widget which adds a "lang"
    attribute to each option, as required by accessibility standards.

    @author Don Baccus (dhogaza@pacifier.com)
    @creation-date November 3, 2006
    @cvs-id $Id$
}

namespace eval template {}
namespace eval template::widget {}

ad_proc -public template::widget::select_locales { element_reference tag_attributes } {

    upvar $element_reference element

    if { [info exists element(html)] } {
        array set attributes $element(html)
    }

    array set attributes $tag_attributes

    append output "<select name=\"$element(name)\" "

    foreach name [array names attributes] {
        if { [string equal $attributes($name) {}] } {
            append output " $name=\"$name\""
        } else {
            append output " $name=\"$attributes($name)\""
        }
    }
    append output ">\n"

    foreach option $element(options) {

        set label [lindex $option 0]
        set value [lindex $option 1]

        set value [template::util::quote_html $value]
        append output " <option lang=\"[string range $value 0 1]\" value=\"$value\""
        if { [info exists values($value)] } {
            append output " selected=\"selected\""
        }

        append output ">$label</option>\n"
    }
    append output "</select>"

    return $output

}
