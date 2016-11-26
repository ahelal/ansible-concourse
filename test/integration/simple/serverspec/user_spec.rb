require_relative '../../helper_spec.rb'

describe user('concourseci') do
  it { should exist }
end

describe group('concourseci') do
  it { should exist }
end

