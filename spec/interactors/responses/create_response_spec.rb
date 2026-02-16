require 'rails_helper'

RSpec.describe Responses::CreateResponse, type: :interactor do
    let(:user) { create(:user) }
    let(:lesson) { create(:lesson) }
    let(:params) { { content: 'This is my response' } }
    
    subject(:context) { described_class.call(user: user, lesson: lesson, params: params) }
    
    describe 'creating a response' do
        context 'with valid parameters' do
            it 'creates a new response' do
                expect { context }.to change(Response, :count).by(1)
            end
        end

        context 'with invalid parameters' do
            let(:params) { { content: '' } }

            it 'does not create a new response' do
                expect { context }.not_to change(Response, :count)
            end

            it 'returns an error message' do
                expect(context.error).to eq('Content can\'t be blank')
            end
        end
    end
end
