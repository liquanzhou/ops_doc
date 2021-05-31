gitlab-ldap.sh




gitlab_rails['ldap_enabled'] = true

###! **remember to close this block with 'EOS' below**
gitlab_rails['ldap_servers'] = YAML.load <<-'EOS'
   main: # 'main' is the GitLab 'provider ID' of this LDAP server
     label: 'LDAP'
     host: '172.16.1.233'
     port: 10389
     uid: 'uid'
     bind_dn: 'uid=git,ou=People,dc=xiaochuankeji,dc=cn'
     password: 'E5yN7MinWAoHxZTl'
     encryption: 'plain' # "start_tls" or "simple_tls" or "plain"
     active_directory: true
     allow_username_or_email_login: true
     block_auto_created_users: false
     base: 'ou=People,dc=xiaochuankeji,dc=cn'
     user_filter: '(houseIdentifier=git)'
     attributes:
       username: ['uid', 'userid', 'sAMAccountName']
       email:    ['mail', 'email', 'userPrincipalName']
       name:       'cn'
       first_name: 'givenName'
       last_name:  'sn'
     ## EE only
     group_base: ''
     admin_group: ''
     sync_ssh_keys: 'publicKey'
EOS



# user_filter  过滤登陆条件


gitlab-ctl restart
gitlab-ctl reconfigure