# InSpec test for wag_access_sysadmin::default recipe on RHEL

control 'sysadmin-sudo-1' do
  impact 1.0
  title 'Sysadmin group should have a sudoers entry'
  desc 'Verify that the sysadmin group is granted sudo privileges via /etc/sudoers.d/50sysadmin'

  describe file('/etc/sudoers.d/50sysadmin') do
    it { should exist }
    it { should be_file }
    its('mode') { should cmp '0440' }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
  end

  # Validate the sudoers file syntax
  describe command('visudo -cf /etc/sudoers.d/50sysadmin') do
    its('exit_status') { should eq 0 }
  end
end

control 'sysadmin-sudo-2' do
  impact 1.0
  title 'Sysadmin group should be allowed to run all commands via sudo'
  desc 'Check sudoers file content to ensure sysadmin group has ALL permissions'

  describe file('/etc/sudoers.d/50sysadmin') do
    its('content') { should match(/^%sysadmin\s+ALL=\(ALL\)\s+ALL$/) }
  end
end

control 'sysadmin-group-1' do
  impact 0.7
  title 'Sysadmin group should exist'
  desc 'Ensure that the sysadmin group is present on the system'

  describe group('sysadmin') do
    it { should exist }
  end
end
