ad_page_contract {
    Edit description of message key.

    @author Simon Carstensen
    @creation-date 2003-08-13
} {
    locale
    package_key
    message_key
    show:optional
    {description ""}
}

# We rename to avoid conflict in queries
set current_locale $locale
set default_locale en_US

set locale_label [ad_locale_get_label $current_locale]
set default_locale_label [ad_locale_get_label $default_locale]

set page_title "Edit description"
set context [list [list "package-list?[export_vars { locale }]" $locale_label] \
                 [list "message-list?[export_vars { locale package_key message_key show }]" $package_key] \
                 [list "edit-localized-message?[export_vars { locale package_key message_key show }]" "$package_key.$message_key"] \
                 $page_title]


ad_form -name description -form {
    {locale:text(hidden)}
    {package_key:text(hidden)}
    {message_key:text(hidden)}
    {show:text(hidden)}

    {message_key_pretty:text(inform)
        {value "$package_key.$message_key"}
        {label "Message Key"}
    }
    {description:text(textarea),optional
        {label "Description"}
        {html { rows 15 cols 60 }}
    }
    {org_message:text(inform)
        {label "$default_locale_label Message"}
    }

    {submit:text(submit)
        {label "     Update     "}
    }
} -on_request { 
    db_1row select_description {}
} -on_submit {

    lang::message::update_description \
        -package_key $package_key \
        -message_key $message_key \
        -description $description

    ad_returnredirect "edit-localized-message?[export_vars { locale package_key message_key show }]"
    ad_script_abort
}
