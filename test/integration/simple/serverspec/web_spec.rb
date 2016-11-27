require_relative '../../helper_spec.rb'

describe port(8080) do
  it 'concourse web to be listenting to connection' do
    expect(subject).to be_listening
  end
end

describe process('concourse') do
  it 'concourse web process to be running with concourse user' do
    expect(subject.user).to match('concourseci')
    expect(subject.args).to match('web')
  end
end
