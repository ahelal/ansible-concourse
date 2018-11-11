require_relative '../../helper_spec.rb'

describe file('/opt/concourseci/bin/concourse-web') do
    it { should_not exist }
end


# Concourse web process to be running with concourse user
describe command('pgrep -u concourseci -f concourse\\ web -c') do
    its(:exit_status) { should eq 1 }
    its(:stdout) { should match '0' }
  end
