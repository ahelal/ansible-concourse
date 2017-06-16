require_relative '../../helper_spec.rb'

describe command('/usr/local/bin/fly -t kitchen teams') do
  it 'simple_success are in the builds' do
    expect(subject.stdout).to match('simple_success')
    expect(subject.exit_status).to eq(0)
  end
end
