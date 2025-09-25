control 'svcauto-1.0' do
  impact 1.0
  title 'Verify svcauto user and group setup on RedHat'
  desc 'Ensure svcauto user and nogroup group exist with correct UID/GID and home directory'

  describe group('nogroup') do
    it { should exist }
    its('gid') { should cmp 65534 }
  end

  describe user('svcauto') do
    it { should exist }
    its('uid') { should cmp 26599 }
    its('gid') { should cmp 65534 }
    its('home') { should eq '/home/users/svcauto' }
    its('shell') { should match(/sh|bash/) } # allow sh/bash
  end
end

control 'svcauto-2.0' do
  impact 1.0
  title 'Verify svcauto home directory permissions'
  desc 'Ensure /home/users/svcauto and .ssh exist with correct ownership and permissions'

  describe file('/home/users/svcauto') do
    it { should exist }
    it { should be_directory }
    its('mode') { should cmp '0755' }
    its('owner') { should eq 'svcauto' }
    its('group') { should eq 'nogroup' }
  end

  describe file('/home/users/svcauto/.ssh') do
    it { should exist }
    it { should be_directory }
    its('mode') { should cmp '0700' }
    its('owner') { should eq 'svcauto' }
    its('group') { should eq 'nogroup' }
  end
end

control 'svcauto-3.0' do
  impact 1.0
  title 'Verify svcauto SSH authorized_keys'
  desc 'Ensure authorized_keys file exists with proper permissions'

  describe file('/home/users/svcauto/.ssh/authorized_keys') do
    it { should exist }
    it { should be_file }
    its('mode') { should cmp '0600' }
    its('owner') { should eq 'svcauto' }
    its('group') { should eq 'nogroup' }
  end
end

control 'svcauto-4.0' do
  impact 1.0
  title 'Verify sudo privileges for svcauto'
  desc 'Ensure svcauto can run chef-client and related services without password'

  describe file('/etc/sudoers.d/51svcauto') do
    it { should exist }
    it { should be_file }
    its('mode') { should cmp '0440' }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
  end

  describe command("sudo -l -U svcauto") do
    its('stdout') { should match(%r{/usr/bin/chef-client}) }
    its('stdout') { should match(%r{/bin/systemctl (status|start|stop|restart) chef-client}) }
    its('stdout') { should match(%r{/bin/systemctl (status|start|stop|restart) chef-start}) }
  end
end
