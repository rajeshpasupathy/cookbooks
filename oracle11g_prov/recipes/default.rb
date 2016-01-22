#
# Cookbook Name:: oracle11g_prov
# Recipe:: default
#
# Set up and configure the oracle user.
include_recipe 'oracle11g_prov::oracle_user_config' unless node[:oracle][:rdbms][:is_installed]

## Install dependencies and configure kernel parameters required for oracle rdbms 11204 binaries
# Node attribute changes for 11204, if default[:oracle][:rdbms][:dbbin_version] is set to 11204
if node[:oracle][:rdbms][:dbbin_version] == "11.2.0.4"
include_recipe 'oracle11g_prov::deps_install' unless node[:oracle][:rdbms][:is_installed]
end

# Setting up kernel parameters
include_recipe 'oracle11g_prov::kernel_params' unless node[:oracle][:rdbms][:is_installed]

# Baseline install for Oracle itself
include_recipe 'oracle11g_prov::dbbin' unless node[:oracle][:rdbms][:is_installed]

## Patching oracle binaries to the latest patch
# Node attribute changes for 12c, if default[:oracle][:rdbms][:dbbin_version] is set to 12c
#if node[:oracle][:rdbms][:dbbin_version] == "11.2.0.4"
#  #include_recipe 'oracle::latest_dbpatch' unless node[:oracle][:rdbms][:latest_patch][:is_installed]
include_recipe 'oracle11g_prov::createdb' 
#include_recipe 'oracle11g_prov::db_latest_patch'
#end
