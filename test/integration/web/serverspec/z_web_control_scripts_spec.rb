require_relative '../../helper_spec.rb'

PS_WEB = 'ps ax|grep "/opt/concourseci/bin/concourse web"|grep -v grep'.freeze

## Web stop
describe 'concourse web stopped' do
  describe command('sudo service concourse-web stop') do
    it 'initd script should stop web and return OK' do
      expect(subject.stdout).to match('[ OK ]')
      expect(subject.exit_status).to eq(0)
    end
  end

  describe command('sudo service concourse-web status') do
    it 'initd script should return stopped' do
      expect(subject.stdout).to match('not running')
    end
  end

  describe command(PS_WEB.to_s) do
    it 'ps should report no process running' do
      expect(subject.stdout).to eq('')
    end
  end
end
## Web running
describe 'concourse web running' do
  describe command('sudo service concourse-web start') do
    it 'initd script should start and return running' do
      expect(subject.stdout).to match('[ OK ]')
      expect(subject.exit_status).to eq(0)
    end
  end

  describe command('sudo service concourse-web status') do
    it 'initd script should return running' do
      expect(subject.stdout).to match('running with PID:')
      expect(subject.exit_status).to eq(0)
    end
  end

  describe command(PS_WEB.to_s) do
    it 'ps should report process running' do
      expect(subject.stdout).to match('/opt/concourseci/bin/concourse')
      expect(subject.exit_status).to eq(0)
    end
  end
end
