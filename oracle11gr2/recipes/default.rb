#
# Cookbook Name:: oracle11gr2
# Recipe:: default
#
# Set up and configure the oracle user.
include_recipe 'oracle11gr2::oracle_user_config' unless node[:oracle][:rdbms][:is_installed]

## Install dependencies and configure kernel parameters required for oracle rdbms 11204 binaries
# Node attribute changes for 11204, if default[:oracle][:rdbms][:dbbin_version] is set to 11204
if node[:oracle][:rdbms][:dbbin_version] == "11.2.0.4"
include_recipe 'oracle11gr2::deps_install' unless node[:oracle][:rdbms][:is_installed]
end

# Setting up kernel parameters
include_recipe 'oracle11gr2::kernel_params' unless node[:oracle][:rdbms][:is_installed]

# Baseline install for Oracle itself
include_recipe 'oracle11gr2::dbbin' unless node[:oracle][:rdbms][:is_installed]

## Patching oracle binaries to the latest patch
# Node attribute changes for 12c, if default[:oracle][:rdbms][:dbbin_version] is set to 12c
#if node[:oracle][:rdbms][:dbbin_version] == "11.2.0.4"
#  #include_recipe 'oracle::latest_dbpatch' unless node[:oracle][:rdbms][:latest_patch][:is_installed]
#include_recipe 'oracle11gr2::createdb' 
#include_recipe 'oracle11gr2::db_latest_patch'
#end
