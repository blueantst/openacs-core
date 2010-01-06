alter table acs_data_links add relation_tag varchar2(100);

create index acs_data_links_rel_tag_idx on acs_data_links (relation_tag);

alter table acs_data_links drop constraint acs_data_links_un;

alter table acs_data_links add constraint acs_data_links_un unique 
(object_id_one, object_id_two, relation_tag);