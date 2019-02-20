describe Fastlane::Actions::DingdingtalkAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The dingdingtalk plugin is working!")

      Fastlane::Actions::DingdingtalkAction.run(nil)
    end
  end
end
