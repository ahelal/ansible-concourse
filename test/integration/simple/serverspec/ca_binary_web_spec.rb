require_relative '../../helper_spec.rb'

describe file('/opt/concourseci/bin/concourse-web') do
  it 'concourse-web script has right permission' do
    expect(subject).to be_file
    expect(subject).to be_executable
    expect(subject).to be_owned_by 'root'
  end
end
