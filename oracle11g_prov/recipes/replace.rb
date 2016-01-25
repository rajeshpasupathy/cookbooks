ruby_block "testing replace function" do
  block do
    fe = Chef::Util::FileEdit.new("/etc/sudoers")
    fe.search_file_replace("Defaults requiretty", "#Defaults requiretty")
    fe.write_file
  end  
end