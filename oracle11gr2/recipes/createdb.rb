# Cookbook Name:: Oracle11gR2_Prov
# Recipe:: createdb
# Create Oracle databases.
#

directory node[:oracle][:rdbms][:dbs_root] do
  owner 'oracle'
  group 'dba'
  mode '0755'
  recursive true
end

# createdb.rb uses this database template.
template "#{node[:oracle][:rdbms][:ora_home]}/assistants/dbca/templates/default_template.dbt" do
  owner 'oracle'
  group 'dba'
  mode '0644'
end

# Optional database template with more db options.
template "#{node[:oracle][:rdbms][:ora_home]}/assistants/dbca/templates/midrange_template.dbt" do
  owner 'oracle'
  group 'dba'
  mode '0644'
end

# Iterate over :oracle[:rdbms][:dbs]'s keys, Initializing dbca to
# create a database named after the key for each key whose associated
# value is false, and flipping the value afterwards.
# If :oracle[:rdbms][:dbs] is empty, we print a warning to STDOUT.
ruby_block "print_empty_db_hash_warning" do
  block do
    Chef::Log.warn(":oracle[:rdbms][:dbs] is empty; no database will be created.")
  end
  action :create
  only_if {node[:oracle][:rdbms][:dbs].empty?}
end

node[:oracle][:rdbms][:dbs].each_key do |db|
  if node[:oracle][:rdbms][:dbs][db]
    ruby_block "print_#{db}_skipped_msg" do
      block do
        Chef::Log.info("Database #{db} has already been created on this node- skipping it.")
    end
      action :create
  end
  next
 end

  ## Create database. 
  if node[:oracle][:rdbms][:dbbin_version] == "11.2.0.4"
    bash "dbca_createdb_#{db}" do
      user "oracle"
      group "dba"
      environment (node[:oracle][:rdbms][:env])
      code "dbca -silent -createDatabase -templateName #{node[:oracle][:rdbms][:db_create_template]} -gdbname #{db} -sid #{db} -sysPassword #{node[:oracle][:rdbms][:sys_pw]} -systemPassword #{node[:oracle][:rdbms][:system_pw]}"
    end

  end # of create database.

  # Setting a flag to indicate, that the database has been created.
  ruby_block "set_#{db}_install_flag" do
    block do
      node.set[:oracle][:rdbms][:dbs][db] = true
    end
    action :create
  end
# Append to tnsnames.ora a stanza describing the new DB
   execute "append_#{db}_to_tnsnames.ora" do
    command "echo '#{db} =\n  (DESCRIPTION =\n    (ADDRESS_LIST =\n      (ADDRESS = (PROTOCOL = TCP)(HOST = #{node[:fqdn]})(PORT = 1526))\n    )\n    (CONNECT_DATA =\n      (SERVICE_NAME = #{db})\n    )\n  )\n\n' >> #{node[:oracle][:rdbms][:ora_home]}/network/admin/tnsnames.ora"
    not_if "grep #{db} #{node[:oracle][:rdbms][:ora_home]}/network/admin/tnsnames.ora > /dev/null 2>&1"
  end

 # Set the ORACLE_SID correctly in oracle's .profile.
  execute "set_oracle_sid_to_oracle_profile_#{db}" do
    command "sed -i 's/ORACLE_SID=.*/ORACLE_SID=#{db}/g' /optware/oracle/.profile"
    user 'oracle'
    group 'dba'
    environment (node[:oracle][:rdbms][:env])
  end

# Set the ORACLE_UNQNAME correctly in oracle's .profile.
  execute "set_oracle_unqname_to_oracle_profile_#{db}" do
    command "sed -i 's/ORACLE_UNQNAME=.*/ORACLE_UNQNAME=#{db}/g' /optware/oracle/.profile"
    user 'oracle'
    group 'dba'
    environment (node[:oracle][:rdbms][:env])
  end
end
