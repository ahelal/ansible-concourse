require_relative '../../helper_spec.rb'

fly = '/usr/local/bin/fly -t kitchen'

describe 'teams' do
  describe command("#{fly} teams | grep main | grep -v grep") do
    it 'main should exist' do
      expect(subject.stdout).to match('main')
    end
  end

  describe command("#{fly} teams | grep x1 | grep -v grep") do
    it 'main should exist' do
      expect(subject.stdout).to match('x1')
    end
  end

  describe command("#{fly} teams | grep x3 | grep -v grep") do
    it 'main should exist' do
      expect(subject.stdout).to match('x3')
    end
  end

  describe command("#{fly} teams | grep x4 | grep -v grep") do
    it 'main should exist' do
      expect(subject.stdout).to match('x4')
    end
  end
end

describe 'users login' do
  describe command("#{fly} login -n x1 -u user1 -p pass1") do
    it 'user1 should be part of x1' do
      expect(subject.stdout).to match('target saved')
      expect(subject.exit_status).to eq(0)
    end
  end
  describe command("#{fly} login -n x3 -u user2 -p pass2") do
    it 'user2 should be part of x3' do
      expect(subject.stdout).to match('target saved')
      expect(subject.exit_status).to eq(0)
    end
  end
  describe command("#{fly} login -n x4 -u user4 -p pass4") do
    it 'user4 should be part of x4' do
      expect(subject.stdout).to match('target saved')
      expect(subject.exit_status).to eq(0)
    end
  end
  describe command("#{fly} login -n main -u user1 -p pass1") do
    it 'user1 should be part of main' do
      expect(subject.stdout).to match('target saved')
      expect(subject.exit_status).to eq(0)
    end
  end
end
