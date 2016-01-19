#
# Cookbook Name:: GCT_Oracle11gR2_DB_Prov
# Recipe:: deps_install
## Install Oracle RDBMS' dependencies.
## Install Oracle RDBMS' dependencies.
#

#template "/etc/yum.repos.d/soe6gdeproducts.repo" do
#  action :create_if_missing
 # source 'soe6gdeproducts.repo.erb'
 # owner 'root'
 # group 'root'
#end

node[:oracle][:rdbms][:deps].each do |dep|
  yum_package dep
end
