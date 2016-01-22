#
# Cookbook Name:: oracle11g_prov
# Recipe:: kernel_params
#
# ## Configure kernel parameters for Oracle RDBMS.
#

node.set[:phymem] = ((node['memory']['total'][0..-3].to_i) * 1024) * 3 / 4

ruby_block "ensure kernel parameters are set" do
  block do
        fe = Chef::Util::FileEdit.new("/etc/sysctl.conf")
        fe.insert_line_if_no_match(/kernel.sem = 250 32000 100 128/,"kernel.sem = 250 32000 100 128")
        fe.insert_line_if_no_match(/kernel.shmmni = 4096/,"kernel.shmmni = 4096")
        fe.insert_line_if_no_match(/fs.aio-max-nr = 1048576/,"fs.aio-max-nr = 1048576")
        fe.insert_line_if_no_match(/fs.file-max = 6815744/,"fs.file-max = 6815744")
        fe.insert_line_if_no_match(/net.ipv4.ip_local_port_range = 9000 65500/,"net.ipv4.ip_local_port_range = 9000 65500")
        fe.insert_line_if_no_match(/net.core.rmem_default = 262144/,"net.core.rmem_default = 262144")
        fe.insert_line_if_no_match(/net.core.rmem_max = 4194304/,"net.core.rmem_max = 4194304")
        fe.insert_line_if_no_match(/net.core.wmem_default = 262144/,"net.core.wmem_default = 262144")
        fe.insert_line_if_no_match(/net.core.wmem_max = 1048586/,"net.core.wmem_max = 1048586")
        fe.insert_line_if_no_match(/kernel.shmmax = #{node['phymem']}/,"kernel.shmmax = #{node[:phymem]}")
    fe.write_file
  end
  #not_if { Resolv.getaddress "kernel.sem = 250 32000 100 128" rescue false }
end

bash 'sysctl_reload' do
  code '/sbin/sysctl -p'
  action :run
end
