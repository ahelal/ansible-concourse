require_relative '../../helper_spec.rb'

fly = '/usr/local/bin/fly -t kitchen'
builds = "#{fly} builds"




describe 'simple_success job' do
  describe command("#{builds} | grep simple_success") do
    it 'simple_success are in the builds' do
        puts "#################################"
        puts  "#{subject.stdout}"
        puts "#################################"
      expect(subject.stdout).to match('simple_success')
      expect(subject.exit_status).to eq(0)
    end
  end

  describe command("#{builds} | grep simple_success | head -1 | awk '{ print $4 }'") do
    it 'simple_success pipeline should succeed' do
        puts "#################################"
        puts  "#{subject.stdout}"
        puts "#################################"
      expect(subject.stdout).to match('succeeded')
      expect(subject.exit_status).to eq(0)
    end
  end

  describe command("#{fly} watch -b $(#{builds} | grep simple_success | head -1 | awk '{ print $1 }')") do
    it 'simple_success pipeline log should have "I WILL SUCCESSED"' do
        puts "#################################"
        puts  "#{subject.stdout}"
        puts "#################################"
      expect(subject.stdout).to match('I WILL SUCCESSED')
      expect(subject.exit_status).to eq(0)
    end
  end
end

describe 'simple_failure job' do
  describe command("#{builds} | grep simple_failure") do
    it 'simple_failure are in the builds' do
      expect(subject.stdout).to match('simple_failure')
      expect(subject.exit_status).to eq(0)
    end
  end

  describe command("#{builds} | grep simple_failure | head -1 | awk '{ print $4 }'") do
    it 'simple_success pipelines should be failed' do
      expect(subject.stdout).to match('failed')
      expect(subject.exit_status).to eq(0)
    end
  end

  describe command("#{fly} watch -b $(#{builds} | grep simple_failure | head -1 | awk '{ print $1 }')") do
    it 'simple_failure pipelines log should have "I WILL FAIL"' do
      expect(subject.stdout).to match('I WILL FAIL')
      expect(subject.exit_status).to eq(1)
    end
  end
end
