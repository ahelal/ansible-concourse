require_relative '../../helper_spec.rb'

describe file('/opt/concourseci/bin/concourse-worker') do
    it { should_not exist }
end

# Concourse worker process to be running with concourse user
describe command('pgrep -u root -f concourse\\ worker -c') do
    its(:exit_status) { should eq 1 }
    its(:stdout) { should match '0' }
end
