require_relative '../../helper_spec.rb'

describe command('/usr/local/bin/fly -t kitchen workers | wc -l') do
  it 'concourse worker should be registered' do
    expect(subject.stdout).to match('1')
    expect(subject.exit_status).to eq(0)
  end
end
