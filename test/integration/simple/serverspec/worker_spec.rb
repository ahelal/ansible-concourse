require_relative '../../helper_spec.rb'

describe command('/usr/local/bin/fly -t kitchen workers | wc -l') do
  it 'concourse worker should be registered' do
    expect(subject.stdout).to match('1')
    expect(subject.exit_status).to eq(0)
  end
end

# Concourse web process to be running with concourse user
describe command("pgrep -u root -f concourse\\ worker -c") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match '1' }
end
