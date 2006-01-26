ad_library {
    Rich text input widget and datatype for OpenACS templating system.

    @author Lars Pind (lars@pinds.com)
    @creation-date 2003-01-27
    @cvs-id $Id$
}

namespace eval template {}
namespace eval template::data {}
namespace eval template::data::transform {}
namespace eval template::data::validate {}
namespace eval template::util {}
namespace eval template::util::richtext {}
namespace eval template::widget {}

ad_proc -public template::util::richtext { command args } {
    Dispatch procedure for the richtext object
} {
  eval template::util::richtext::$command $args
}

ad_proc -public template::util::richtext::create {
    {contents {}}
    {format {}}
} {
    return [list $contents $format]
}

ad_proc -public template::util::richtext::acquire { type { value "" } } {
    Create a new richtext value with some predefined value
    Basically, create and set the richtext value
} {
  set richtext_list [template::util::richtext::create]
  return [template::util::richtext::set_property $type $richtext_list $value]
}

ad_proc -public template::util::richtext::formats {} {
    Returns a list of valid richtext formats
} {
    return { text/enhanced text/plain text/html text/fixed-width }
}

ad_proc -public template::util::richtext::format_options {} {
    Returns a formatting option list
} {
    return { 
        {"Enhanced Text" text/enhanced}
        {"Plain Text" text/plain}
        {"Fixed-width Text" text/fixed-width}
        {"HTML" text/html}
    }
}

ad_proc -public template::data::validate::richtext { value_ref message_ref } {

    upvar 2 $message_ref message $value_ref richtext_list

    set contents    [lindex $richtext_list 0]
    set format      [lindex $richtext_list 1]

    if { ![empty_string_p $contents] && [lsearch -exact [template::util::richtext::formats] $format] == -1 } {
	set message "Invalid format, '$format'."
	return 0
    }

    # enhanced text and HTML needs to be security checked
    if { [lsearch { text/enhanced text/html } $format] != -1 } {
        set check_result [ad_html_security_check $contents]
        if { ![empty_string_p $check_result] } {
            set message $check_result
            return 0
        }
    }

    return 1
}    

ad_proc -public template::data::transform::richtext { element_ref } {

    upvar $element_ref element
    set element_id $element(id)

    set contents [ns_queryget $element_id]
    set format [ns_queryget $element_id.format]

    if { [empty_string_p $contents] } {
        # We need to return the empty list in order for form builder to think of it 
        # as a non-value in case of a required element.
        return [list]
    } else {
        return [list [list $contents $format]]
    }
}

ad_proc -public template::util::richtext::set_property { what richtext_list value } {
    Set a property of the richtext datatype. 

    @param what One of
      <ul>
        <li>contents (synonyms content, text)</li>
        <li>format (synonym mime_type)</li>
      </ul>

    @param richtext_list the richtext list to modify
    @param value the new value

    @return the modified list
} {
    set contents [lindex $richtext_list 0]
    set format   [lindex $richtext_list 1]

    switch $what {
        contents - content - text {
            # Replace contents with value
            return [list $value $format]
        }
        format - mime_type {
            # Replace format with value
            return [list $contents $value]
        }
        default {
            error "Invalid property $what, valid properties are text (synonyms content, contents), mime_type (synonym format)."
        }
    }
}

ad_proc -public template::util::richtext::get_property { what richtext_list } {
    
    Get a property of the richtext datatype. Valid proerties are: 
    
    @param what the name of the property. Must be one of:
    <ul>
    <li>contents (synonyms content, text) - returns the actual contents of the textarea field</li>
    <li>format (synonym mime_type) - returns the mimetype, e.g. 'text/plain'</li>
    <li>html_value - returns the content converted to html format, regardless of the format the content is actually in. In case it is already text/html no conversion will be applied.</li></ul>

    @param richtext_list a richtext datatype value, usually created with ad_form.
} {
    set contents  [lindex $richtext_list 0]
    set format    [lindex $richtext_list 1]

    switch $what {
        content - contents - text {
            return $contents
        }
        format - mime_type {
            return $format
        }
        html_value {
            if { ![empty_string_p $contents] } {
                return [ad_html_text_convert -from $format -to "text/html" -- $contents]
            } else {
                return {}
            }
        }

        default {
            error "Parameter supplied to util::richtext::get_property 'what' must be one of: 'contents', 'format', 'html_value'. You specified: '$what'."
        }
    }
}

ad_proc -public -deprecated template::widget::richtext_htmlarea { element_reference tag_attributes } {
    Implements the richtext widget, which offers rich text editing options.

    If the acs-templating.UseHtmlAreaForRichtextP parameter is set to true (1), this will use the htmlArea WYSIWYG editor widget.
    Otherwise, it will use a normal textarea, with a drop-down to select a format. The available formats are:
    <ul>
    <li>Enhanced text = Allows HTML, but automatically inserts line and paragraph breaks.
    <li>Plain text = Automatically inserts line and paragraph breaks, and quotes all HTML-specific characters, such as less-than, greater-than, etc.
    <li>Fixed-width text = Same as plain text, but conserves spacing; useful for tabular data.
    <li>HTML = normal HTML.
    </ul>
    You can also parameterize the richtext widget with a 'htmlarea_p' attribute, which can be true or false, and which will override the parameter setting.

    @see template::widget::richtext
} {

  upvar $element_reference element

  if { [info exists element(html)] } {
    array set attributes $element(html)
  }

  array set attributes $tag_attributes

  if { [info exists element(value)] } {
      set contents [template::util::richtext::get_property contents $element(value)]
      set format   [template::util::richtext::get_property format $element(value)]
  } else {
      set contents {}
      set format {}
  }
  
  set output {}

  if { [string equal $element(mode) "edit"] } {
      append output {<script language="javascript"><!--} \n {acs_RichText_WriteButtons();  //--></script>}
      
      set attributes(id) "richtext__$element(form_id)__$element(id)"
      
      if { [exists_and_not_null element(htmlarea_p)] } {
          set htmlarea_p [template::util::is_true $element(htmlarea_p)]
      } else {
          set htmlarea_p [parameter::get \
                              -package_id [apm_package_id_from_key "acs-templating"] \
                              -parameter "UseHtmlAreaForRichtextP" \
                              -default 0]
      }

      # Check browser's User-Agent header for compatibility with htmlArea
      if { $htmlarea_p } {
          set user_agent [string tolower [ns_set get [ns_conn headers] User-Agent]]
          if { [string first "opera" $user_agent] != -1 } { 
              # Opera - doesn't work, even though Opera claims to be IE
              set htmlarea_p 0
          } elseif { [regexp {msie ([0-9]*)\.([0-9]+)} $user_agent matches major minor] } {
              # IE, works for browsers > 5.5
              if { $major < 5 || ($major == 5  && $minor < 5) } {
                  set htmlarea_p 0
              }
          } elseif { [regexp {gecko/0*([1-9][0-9]*)} $user_agent match build] } {
              if { $build < 20030210 } {
                  set htmlarea_p 0
              }
          } else {
              set htmlarea_p 0
          }
      }

      if { $htmlarea_p } {
          # Tell the blank-master to include the special stuff for htmlArea in the page header
          global acs_blank_master__htmlareas
          lappend acs_blank_master__htmlareas $attributes(id)
      }

      append output [textarea_internal "$element(id)" attributes $contents]
      if { $htmlarea_p } {
          append output "<input name='$element(id).format' value='text/html' type='hidden'/>"
      } else {
          append output "<br/>Format: [menu $element(id).format [template::util::richtext::format_options] $format attributes]"
      }
          
      # Spell-checker
      array set spellcheck [template::util::spellcheck::spellcheck_properties -element_ref element]
      if { $spellcheck(render_p) } {
          append output " Spellcheck: [menu "$element(id).spellcheck" [nsv_get spellchecker lang_options] $spellcheck(selected_option) attributes]"
      }
  } else {
      # Display mode
      if { [info exists element(value)] } {
          append output [template::util::richtext::get_property html_value $element(value)]
          append output "<input type=\"hidden\" name=\"$element(id)\" value=\"[ad_quotehtml $contents]\">"
          append output "<input type=\"hidden\" name=\"$element(id).format\" value=\"[ad_quotehtml $format]\">"
      }
  }
      
  return $output
}



ad_proc -public template::widget::richtext { element_reference tag_attributes } {
  Implements the richtext widget, which offers rich text editing options.

  This version supports the rte and xinha editor.

  If the acs-templating.UseHtmlAreaForRichtextP parameter is set to true (1), 
  this will use the htmlArea WYSIWYG editor widget.
  Otherwise, it will use a normal textarea, with a drop-down to select a format. 
  The available formats are:
  <ul>
  <li>Enhanced text = Allows HTML, but automatically inserts line and paragraph breaks.
  <li>Plain text = Automatically inserts line and paragraph breaks, and quotes 
      all HTML-specific characters, such as less-than, greater-than, etc.
  <li>Fixed-width text = Same as plain text, but conserves spacing; useful 
      for tabular data.
  <li>HTML = normal HTML.
  </ul>
  You can also parameterize the richtext widget with a 'htmlarea_p' attribute, 
  which can be true or false, and which will override the parameter setting.
<p>
  The default editor in wysigwig mode is rte. In oder to use xinha, one
  has to use 'editor xinha' in the options of the form field. The following
  options for xinha may be specified:
  <ul>
  <li> <em>editor</em>: xinha
  <li> <em>height</em>: height of the xinha widget (e.g. 350px)
  <li> <em>width</em>: width of the xinha widget (e.g. 500px)
  <li> <em>plugins</em>: tcl list of plugins to be used in xinha. There
     is an a special plugin for the oacs file selector available, called OacsFs. 
     If no options are specified, the following plugins will be loaded:
  <pre>
          GetHtml CharacterMap ContextMenu FullScreen
	  ListType TableOperations EditTag LangMarks Abbreviation
  </pre>
     <p>
     These options are used by the OacsFs plugin
     <ul>
    <li> <em>folder_id</em>: the folder from which files should be taken
      for the file selector. Can be used alterantive with fs_package_id, whatever
      more handy in the application.
    <li> <em>fs_package_id</em>: the package id of the file_storage package 
      from which files should be taken
      for the file selector. Can be used alterantive with folder_id, whatever
      more handy in the application. If nothing is specified, the
      globally mounted file-store is used.
    <li> <em>file_types</em>: SQL match pattern for selecting certain types
      of files (e.g. pdf files). The match pattern is applied on the MIME
      type of the field. E.g. a value of %text/% allows any kind of text
      files to be selected, while %pdf% could be used for pdf-files. If
      nothing is specified, all file-types are presented.
    </ul>
  </ul>
  
  Example for the use of the xinha widget with options: 
  <pre>
   text:richtext(richtext),nospell,optional 
	  {label #xowiki.content#} 
	  {options {editor xinha plugins OacsFs height 350px file_types %pdf%}}
	  {html {rows 15 cols 50 style {width: 100%}}}
  </pre>

  Caveat: the three adp-files needed for the OpenACS file selector 
     (insert-image, insert-ilink and file-selector)
     are currently part of the xowiki package, since acs-templating
     is per default not mounted. This is hopefully only a temporal situation
     and we find a better place.
  <p>
  Derived from the htmlarea richtext widget for htmlarea by lars@pinds.com<br/>
  modified for RTE http://www.kevinroth.com/ by davis@xarg.net<br/>
  xinha support by gustaf.neumann@wu-wien.ac.at
} {

  upvar $element_reference element
  set output ""
  
  if { [info exists element(html)] } {
    array set attributes $element(html)
  }

  array set attributes $tag_attributes

  if { [info exists element(value)] } {
    set contents [template::util::richtext::get_property contents $element(value)]
    set format   [template::util::richtext::get_property format $element(value)]
  } else {
    set contents {}
    set format {}
  }

  array set options [expr {[info exists element(options)] ? 
			   $element(options) : ""}]
  set richtextEditor [expr {[info exists options(editor)] ?
			     $options(editor) : "rte"}]

  if { $element(mode) eq "edit" } {
    set attributes(id) "richtext__$element(form_id)__$element(id)"

    if { [exists_and_not_null element(htmlarea_p)] } {
      set htmlarea_p [template::util::is_true $element(htmlarea_p)]
    } else {
      set htmlarea_p [parameter::get \
			  -package_id [apm_package_id_from_key "acs-templating"] \
			  -parameter "UseHtmlAreaForRichtextP" \
			  -default 0]
    }

    set format_menu [menu $element(id).format [template::util::richtext::format_options] $format {}]
    set output [textarea_internal $element(id) attributes $contents]

    if { $htmlarea_p } {
      # Tell the blank-master to include the special stuff 
      # for the richtext widget in the page header
      
      set ::acs_blank_master($richtextEditor) 1
      
      if {$richtextEditor eq "rte"} {
	lappend ::acs_blank_master__htmlareas $element(form_id)
	# quote contents for javascript.
	set contents [string map {\n \\n \r {} "'" "&\#39"} $contents]

	# What we are generating here is the call to write the richtext widget 
	# but we also need to pass what to generate in for browsers for 
	# which the richtext widget won't work but which do have js enabled 
	# should output since we need the format widget (this for Safari among 
	# some others)
	append output "<noscript><br/>Format: $format_menu</noscript>\n"

	set output "<script type='text/javascript'><!--\nwriteRichText('$element(id)','$contents',500,200,true,false,'<input name=\"$element(id).format\" value=\"text/html\" type=\"hidden\"/>','[string map {\n \\n \r {} "'" "&\#39"} $output]'); //--></script><noscript id=\"rte-noscr-$element(id)\">$output</noscript>"
      } elseif {$richtextEditor eq "xinha"} {
	
	append output "<script>document.write(\"<input name='$element(id).format' value='text/html' type='hidden'/>\");</script>\n"
	append output "<noscript><br/>Format: $format_menu</noscript>\n"
	
	# we have a xinha richtext widget, specified by "options {editor xinha}"
	# The following options are supported: 
	#      editor plugins width height folder_id fs_package_id
	#
	set plugins {GetHtml CharacterMap ContextMenu FullScreen
	  ListType TableOperations EditTag LangMarks Abbreviation}
	if {[info exists options(plugins)]} {
	  set plugins $options(plugins)
	}
	set quoted [list]
	foreach e $plugins {lappend quoted '$e'}
	set ::acs_blank_master(xinha.plugins) [join $quoted ", "]

	set xinha_options ""
	foreach e {width height folder_id fs_package_id file_types} {
	  if {[info exists options($e)]} {
	    append xinha_options "xinha_config.$e = '[ad_urlencode $options($e)]';\n"
	  }
	}
	set ::acs_blank_master(xinha.options) $xinha_options
	lappend ::acs_blank_master__htmlareas $attributes(id)
      } 

    } else {
      append output "<br/>Format: $format_menu"
    }

    # Spell-checker
    array set spellcheck [template::util::spellcheck::spellcheck_properties \
			      -element_ref element]
    if { $spellcheck(render_p) } {
      append output " Spellcheck: " \
	  [menu "$element(id).spellcheck" [nsv_get spellchecker lang_options] \
	       $spellcheck(selected_option) attributes]
    }
  } else {
    # Display mode
    if { [info exists element(value)] } {
      append output [template::util::richtext::get_property html_value $element(value)]
      append output "<input type='hidden' name='$element(id)' value='[ad_quotehtml $contents]'>"
      append output "<input type='hidden' name='$element(id).format' value='[ad_quotehtml $format]'>"
    }
  }
  
  return $output
}


