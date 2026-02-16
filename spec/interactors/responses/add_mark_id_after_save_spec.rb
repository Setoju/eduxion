require 'rails_helper'

RSpec.describe Responses::AddMarkIdAfterSave, type: :interactor do
    let(:user) { create(:user) }
    let(:response) { create(:response, user: user) }
    let(:mark) { create(:mark, response: response) }

    subject(:context) { described_class.call(response: response, mark: mark) }

    describe '#call' do
        context 'when the response exists' do
            it 'updates the response with the mark_id' do
                expect(context).to be_a_success
                expect(context.response.mark_id).to eq(mark.id)
            end
        end

        context 'when the response does not exist' do
            let(:response) { nil }

            it 'fails with an error message' do
                expect(context).to be_a_failure
                expect(context.error).to match(/Response not found/)
            end
        end
    end
end
