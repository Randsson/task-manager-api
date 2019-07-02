require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { build(:user) }
    
    it { is_expected.to have_many(:tasks).dependent(:destroy) }

    it { is_expected.to validate_presence_of(:email) }
    
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }

    it { is_expected.to validate_confirmation_of(:password) }
    
    it { is_expected.to allow_value('rand@doug.com').for(:email) }

    it { is_expected.to validate_uniqueness_of(:auth_token) }


    describe '#info' do
      it 'returns email, created_at an a token' do
        user.save!
        allow(Devise).to receive(:friendly_token).and_return('abc123xzyTOKEN')

        expect(user.info).to eq("#{user.email} - #{user.created_at} - Token: abc123xzyTOKEN")
      end
    end

    describe '#generate_auth_token!' do
      it 'generates and unique auth token' do
        allow(Devise).to receive(:friendly_token).and_return('abc123xzyTOKEN')
        user.generate_auth_token! 

        expect(user.auth_token).to eq('abc123xzyTOKEN')
      end

      it 'generates a new auth_token when current auth_token already has ben taken' do
        allow(Devise).to receive(:friendly_token).and_return('bbb1111xxxx', 'bbb1111xxxx', 'abcXYZ123')
        current_user = create(:user)
        user.generate_auth_token!

        expect(user.auth_token).not_to eq(current_user.auth_token)
      end
    end
end
