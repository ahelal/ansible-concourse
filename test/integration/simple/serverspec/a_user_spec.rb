require_relative '../../helper_spec.rb'

`cat /var/log/concourse/concourse-worker.log`

describe user('concourseci') do
  it { should exist }
end

describe group('concourseci') do
  it { should exist }
end
