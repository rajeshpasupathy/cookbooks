#
# Cookbook Name:: GCT_Oracle11gR2_DB_Prov
# Recipe:: oracle_user_config
#
# ## Create and configure the oracle user. 
#
# Create the oracle user.
# The argument to useradd's -g option must be an already existing
# group, else useradd will raise an error.
# Therefore, we must create the dba group before we do the oracle user.

group 'dba' do
  gid node[:oracle][:user][:gid]
end

user 'oracle' do
  uid node[:oracle][:user][:uid]
  gid node[:oracle][:user][:gid]
  shell node[:oracle][:user][:shell]
  comment 'Oracle Administrator'
  supports :manage_home => true
end

# Configure the oracle user.
# Make it a member of the appropriate supplementary groups, and
# ensure its environment will be set up properly upon login.
#node[:oracle][:user][:sup_grps].each_key do |grp|
#  group grp do
#   gid node[:oracle][:user][:sup_grps][grp]
#    members ['oracle']
#    append true
#  end
#end

directory '/optware' do
    owner 'oracle'
    group 'dba'
    mode '0755'
    action :create
    recursive true
  end

# Creating $ORACLE_BASE and the $ORACLE_HOME directory.
[node[:oracle][:ora_base], node[:oracle][:ora_inventory], node[:oracle][:rdbms][:install_dir], node[:oracle][:rdbms][:ora_home]].each do |dir|
  directory dir do
    owner 'oracle'
    group 'dba'
    mode '0755'
    action :create
    recursive true
  end
end

template "/optware/oracle/.profile" do
  action :create_if_missing
  source 'ora_profile.erb'
  owner 'oracle'
  group 'dba'
end

user 'oracle' do
  uid node[:oracle][:user][:uid]
  gid node[:oracle][:user][:gid]
  home '/optware/oracle'
  action :modify
  supports :manage_home => false
end
  # --Setting up dba directory.
 # bash 'Copy_dba_files' do
 #  node[:oracle][:rdbms][:dba_files].each do |zip_file|
 #   user 'oracle'
 #  group 'dba'
 #   cwd node[:oracle][:ora_base]
 #   code <<-EOH2
 #   rm -rf dba.OLD
 #   mv dba dba.OLD
 #   unzip #{File.basename(zip_file)}
 #   EOH2
 #  end
 # end

# Set resource limits for the oracle user.
ruby_block "ensure reuired file limits are set" do
  block do
        fe = Chef::Util::FileEdit.new("/etc/security/limits.conf")
        fe.insert_line_if_no_match(/oracle soft nproc 2047/,"oracle soft nproc 2047")
        fe.insert_line_if_no_match(/oracle hard nproc 16384/,"oracle hard nproc 16384")
        fe.insert_line_if_no_match(/oracle soft nofile 1024/,"oracle soft nofile 1024")
        fe.insert_line_if_no_match(/oracle hard nofile 65536/,"oracle hard nofile 65536")
        fe.insert_line_if_no_match(/oracle soft stack  10240/,"oracle soft stack  10240")
    fe.write_file
  end
  not_if { Resolv.getaddress "oracle soft nproc 2047" rescue false }
end

ruby_block "ensure required shell limits are set" do
  block do
        fe = Chef::Util::FileEdit.new("/etc/pam.d/login")
        fe.insert_line_if_no_match(/session required pam_limits.so/,"session required pam_limits.so")
    fe.write_file
  end
  not_if { Resolv.getaddress "session required pam_limits.so" rescue false }
end
