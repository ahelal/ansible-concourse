require_relative '../../helper_spec.rb'

describe port(8080) do
  it 'concourse web to be listenting to connection' do
    expect(subject).to be_listening
  end
end


# Concourse web process to be running with concourse user
describe command("pgrep -u concourseci -f concourse\\ web -c") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match '1' }
end
