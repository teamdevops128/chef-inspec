control 'svcauto-1.0' do
  impact 1.0
  title 'Verify svcauto user and group configuration'
  desc 'Ensures the svcauto account and group are properly created on RedHat systems.'

  describe group('nogroup') do
    it { should exist }
    its('gid') { should eq 65534 }
  end

  describe user('svcauto') do
    it { should exist }
    its('uid') { should eq 26599 }
    its('group') { should eq 'nogroup' }
    its('home') { should eq '/home/users/svcauto' }
  end
end

control 'svcauto-2.0' do
  impact 1.0
  title 'Verify home directory and permissions'
  desc 'Ensures svcauto home and SSH directory are created with correct ownership and permissions.'

  describe file('/home/users/svcauto') do
    it { should exist }
    it { should be_directory }
    it { should be_owned_by 'svcauto' }
    it { should be_grouped_into 'nogroup' }
    its('mode') { should cmp '0755' }
  end

  describe file('/home/users/svcauto/.ssh') do
    it { should exist }
    it { should be_directory }
    it { should be_owned_by 'svcauto' }
    it { should be_grouped_into 'nogroup' }
    its('mode') { should cmp '0700' }
  end
end

control 'svcauto-3.0' do
  impact 1.0
  title 'Verify authorized_keys file'
  desc 'Ensures the authorized_keys file exists and has secure permissions.'

  describe file('/home/users/svcauto/.ssh/authorized_keys') do
    it { should exist }
    it { should be_file }
    it { should be_owned_by 'svcauto' }
    it { should be_grouped_into 'nogroup' }
    its('mode') { should cmp '0600' }
    its('content') { should_not be_empty }
  end
end

control 'svcauto-4.0' do
  impact 1.0
  title 'Verify sudoers file for svcauto'
  desc 'Ensures svcauto has limited passwordless sudo access for Chef commands.'

  describe file('/etc/sudoers.d/51svcauto') do
    it { should exist }
    it { should be_file }
    its('mode') { should cmp '0440' }
    its('content') { should match /svcauto ALL=\(root\) NOPASSWD:/ }
    its('content') { should match %r{/usr/bin/chef-client} }
    its('content') { should match %r{/bin/systemctl start chef-client} }
    its('content') { should_not match /ALL/ }  # ensures no full sudo rights
  end
end
