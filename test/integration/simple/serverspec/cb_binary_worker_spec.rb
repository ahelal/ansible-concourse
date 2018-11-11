require_relative '../../helper_spec.rb'

describe file('/opt/concourseci/bin/concourse-worker') do
  it 'concourse-worker script has right permission' do
    expect(subject).to be_file
    expect(subject).to be_executable
    expect(subject).to be_owned_by 'root'
  end
end
