describe 'SSH port open and listening' do
  describe port(22) do
    it { should be_listening }
  end
end
