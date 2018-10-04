require_relative '../../helper_spec.rb'

PS_WEB = 'ps ax|grep "/opt/concourseci/bin/concourse web"|grep -v grep'.freeze
PS_WRK = 'ps ax|grep "/opt/concourseci/bin/concourse worke"|grep -v grep'.freeze

## Worker stop
describe 'concourse worker stopped' do
  describe command('sudo service concourse-worker stop') do
    it 'initd script should stop worker and return OK' do
      expect(subject.stdout).to match('[ OK ]')
      expect(subject.exit_status).to eq(0)
    end
  end

  describe command('sudo service concourse-worker status') do
    it 'initd script should return stopped' do
      expect(subject.stdout).to match('not running')
      expect(subject.exit_status).to eq(0)
    end
  end

  describe command(PS_WRK.to_s) do
    it 'ps should report no process running' do
      expect(subject.stdout).to eq('')
    end
  end
end
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
## worker running
describe 'concourse worker running' do
  describe command('sudo service concourse-worker start') do
    it 'initd script should start worker and return running' do
      expect(subject.stdout).to match('[ OK ]')
      expect(subject.exit_status).to eq(0)
    end
  end

  describe command('sudo service concourse-worker status') do
    it 'initd script should return running' do
      expect(subject.stdout).to match('running with PID:')
      expect(subject.exit_status).to eq(0)
    end
  end

  describe command(PS_WRK.to_s) do
    it 'ps should report process running' do
      expect(subject.stdout).to match('/opt/concourseci/bin/concourse')
      expect(subject.exit_status).to eq(0)
    end
  end
end
