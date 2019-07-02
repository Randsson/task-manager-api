require 'rails_helper'

RSpec.describe Task, type: :model do
  let(:task) { build(:task) }

   context 'when task is new' do
     it { expect(task).not_to be_done }
   end

   it { is_expected.to belong_to(:user) }

   it { is_expected.to validate_presence_of :title }
   it { is_expected.to validate_presence_of :user_id }

   [:title, :description, :deadline, :done, :user_id].each do |field|
      it { is_expected.to respond_to(field) }
   end
   
end
