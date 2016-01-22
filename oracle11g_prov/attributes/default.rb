#
# Cookbook Name:: oracle11g_Prov
# Attributes::default
#
# 
## Settings specific to the Oracle user.

default[:oracle][:user][:uid] = 59735
default[:oracle][:user][:gid] = 501
default[:oracle][:user][:shell] = '/bin/bash'

# General Oracle settings.
default[:oracle][:ora_base] = '/optware/oracle'
default[:oracle][:ora_inventory] = '/optware/oracle/oraInventory'

## Settings specific to the Oracle RDBMS proper.
default[:oracle][:rdbms][:dbbin_version] = '11.2.0.4'
default[:oracle][:rdbms][:ora_home] = "#{node[:oracle][:ora_base]}/#{node[:oracle][:rdbms][:dbbin_version]}/db_1"
default[:oracle][:rdbms][:is_installed] = true
default[:oracle][:rdbms][:install_info] = {}
default[:oracle][:rdbms][:db_create_template] = 'default_template.dbt'

# Dependencies for Oracle 11.2.
# Source: <https://catecollaboration.citigroup.net/domains/platstor/db/OracleDocs/11.2.0.4/Oracle_Database_11gR24_RHEL_RFP.pdf>
# Required O/S RPMS for RHEL6 recommended by CATE.
default[:oracle][:rdbms][:deps] = ['binutils', 'compat-libcap1', 'compat-libstdc++-33', 'gcc', 'gcc-c++', 'glibc',
                                   'glibc-devel', 'ksh', 'libgcc', 'libstdc++', 'libstdc++-devel', 'libaio',
                                   'libaio-devel', 'make', 'sysstat']

# Oracle environment parameters for database
default[:oracle][:rdbms][:env] = {'ORACLE_BASE' => node[:oracle][:ora_base],
                                  'ORACLE_HOME' => node[:oracle][:rdbms][:ora_home],
                                  'PATH' => "/usr/kerberos/bin:/usr/local/bin:/bin:/usr/bin:/usr/sbin:#{node[:oracle][:ora_base]}/dba/bin:#{node[:oracle][:rdbms][:ora_home]}/bin:#{node[:oracle][:rdbms][:ora_home]}/OPatch"}


default[:oracle][:rdbms][:install_files] = ['https://s3.amazonaws.com/oraclebinaries/rdbms/11204/p13390677_112040_Linux-x86-64_1of7.zip',
                                            'https://s3.amazonaws.com/oraclebinaries/rdbms/11204/p13390677_112040_Linux-x86-64_2of7.zip']

default[:oracle][:rdbms][:dba_files] = ['/nfsmount/chefshare/dbamaint/dba.zip']
default[:oracle][:rdbms][:install_dir] = '/optware/oracle/dbinstall'

default[:oracle][:rdbms][:dbs] = {"GCTCTO" => false}
# The directory under which we install the DBs.
default[:oracle][:rdbms][:dbs_root] = "/oradata"
default[:oracle][:rdbms][:sys_pw] = 'System123'
default[:oracle][:rdbms][:system_pw] = 'System123'
