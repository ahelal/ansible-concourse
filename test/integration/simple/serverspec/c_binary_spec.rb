require_relative '../../helper_spec.rb'

describe file('/opt/concourseci/bin/concourse') do
  it 'concourse binary has right permission' do
    expect(subject).to be_file
    expect(subject).to be_executable
    expect(subject).to be_owned_by 'root'
  end
end

describe command('/opt/concourseci/bin/concourse --help') do
  it 'concourse binary execute and print help' do
    expect(subject.stdout).to match('worker')
    expect(subject.stdout).to match('web')
  end
end

describe file('/opt/concourseci/bin/concourse-web') do
  it 'concourse-web script has right permission' do
    expect(subject).to be_file
    expect(subject).to be_executable
    expect(subject).to be_owned_by 'root'
  end
end

describe file('/opt/concourseci/bin/concourse-worker') do
  it 'concourse-worker script has right permission' do
    expect(subject).to be_file
    expect(subject).to be_executable
    expect(subject).to be_owned_by 'root'
  end
end
