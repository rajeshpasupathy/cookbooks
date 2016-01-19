#
# Cookbook Name:: awstest
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
directory '/test1' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end
