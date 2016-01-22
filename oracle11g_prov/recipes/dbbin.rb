#
#  Cookbook Name:: oracle11g_Prov
# Recipe:: dbbin
## Install Oracle RDBMS binaries.
# We need unzip to expand the install files later on.
yum_package 'unzip'

# Fetching the install media with curl and unzipping them.
# We run two resources to avoid chef-client's runaway memory usage resulting
# in the kernel killing it.

directory "#{node[:oracle][:rdbms][:install_dir]}/database" do
    owner 'oracle'
    group 'dba'
    mode '0755'
    action :delete
    recursive true
  end

# Fetching the install media with curl and unzipping them.
node[:oracle][:rdbms][:install_files].each do |zip_file|
  execute "fetch_oracle_media_#{zip_file}" do
    command "curl -kO #{zip_file}"
    user 'oracle'
    group 'dba'
    cwd node[:oracle][:rdbms][:install_dir]
  end
  execute "unzip_oracle_media_#{zip_file}" do
     command "unzip #{File.basename(zip_file)}"
     user "oracle"
     group 'dba'
     cwd node[:oracle][:rdbms][:install_dir]
  end
end

# Filesystem template.
template "#{node[:oracle][:rdbms][:install_dir]}/db11R24.rsp" do
  owner 'oracle'
  group 'dba'
  mode '0644'
end

if node[:oracle][:rdbms][:dbbin_version] == "11.2.0.4"
  bash 'run_rdbms_installer' do
  cwd "#{node[:oracle][:rdbms][:install_dir]}/database"
  environment (node[:oracle][:rdbms][:env])
   code "sudo -Eu oracle ./runInstaller -showProgress -silent -ignoreInternalDriverError -waitforcompletion -ignoreSysPrereqs -responseFile #{node[:oracle][:rdbms][:install_dir]}/db11R24.rsp -invPtrLoc /optware/oracle/11.2.0.4/db_1/oraInst.loc"
   returns [0, 6]
end
 execute 'root.sh_rdbms' do
  command "#{node[:oracle][:rdbms][:ora_home]}/root.sh"
 end
end  

#execute 'install_dir_cleanup' do
#  command "rm -rf #{node[:oracle][:rdbms][:install_dir]}/*"
#end

# Set a flag to indicate the rdbms has been successfully installed.
ruby_block 'set_rdbms_install_flag' do
  block do
    node.set[:oracle][:rdbms][:is_installed] = true
  end
  action :create
end

template "#{node[:oracle][:rdbms][:ora_home]}/network/admin/listener.ora" do
    owner 'oracle'
    group 'dba'
    mode '0644'
  end
 
 # Starting listener 
  execute 'start_listener' do
    command "#{node[:oracle][:rdbms][:ora_home]}/bin/lsnrctl start"
    user 'oracle'
    group 'dba'
    environment (node[:oracle][:rdbms][:env])
  end
  
  # Append to tnsnames.ora to add LISTENERS entry
  execute "append_LISTENERS_entry_to_tnsnames.ora" do
    command "echo 'LISTENERS =\n    (ADDRESS_LIST =\n      (ADDRESS = (PROTOCOL = TCP)(HOST = #{node[:fqdn]})(PORT = 1526))\n  )\n\n' >> #{node[:oracle][:rdbms][:ora_home]}/network/admin/tnsnames.ora"
    not_if "grep LISTENERS #{node[:oracle][:rdbms][:ora_home]}/network/admin/tnsnames.ora > /dev/null 2>&1"
    user 'oracle'
    group 'dba'
  end