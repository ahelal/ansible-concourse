require_relative '../../helper_spec.rb'

# describe command('while /usr/local/bin/fly -t kitchen builds | grep started > /dev/null; do echo "jobs still running"; sleep 2; done') do
#   it 'No pending jobs' do
#     expect(subject.exit_status).to eq(0)
#   end
# end

describe command('/usr/local/bin/fly -t kitchen builds | grep simple_success') do
  it 'simple_success are in the builds' do
    expect(subject.stdout).to match('simple_success')
    expect(subject.exit_status).to eq(0)
  end
end

describe command('/usr/local/bin/fly -t kitchen builds | grep simple_failure') do
  it 'simple_failure are in the builds' do
    expect(subject.stdout).to match('simple_failure')
    expect(subject.exit_status).to eq(0)
  end
end

describe command('/usr/local/bin/fly -t kitchen builds | grep simple_success | head -1 | awk \'{ print $4 }\'') do
  it 'simple_success pipelines should be succeeded' do
    expect(subject.stdout).to match('succeeded')
    expect(subject.exit_status).to eq(0)
  end
end

describe command('/usr/local/bin/fly -t kitchen builds | grep simple_failure | head -1 | awk \'{ print $4 }\'') do
  it 'simple_success pipelines should be succeeded' do
    expect(subject.stdout).to match('failed')
    expect(subject.exit_status).to eq(0)
  end
end
