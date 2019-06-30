require 'rails_helper'

RSpec.describe 'Users API', type: :request do
    let!(:user) { create(:user) }
    let(:user_id) { user.id }
    let(:headers) do
        {
            'Accept' => 'application/vnd.taskmanager.v1',
            'Content-type' => Mime[:json].to_s
        }
    end

    before { host! 'api.task-manager.test'}

    describe 'GET /users/:id' do
        before do
            get "/users/#{user_id}", params: {}, headers: headers
        end

        context 'when the user exists' do
            it 'returns the user' do
                expect(json[:id]).to eq(user_id)  
            end

            it 'returns status 200' do
                expect(response).to have_http_status(200)
            end
        end

        context 'when user does not exist' do
            let(:user_id) { 100 }

            it 'returns status code 404' do
                expect(response).to have_http_status(404)  
            end
        end
    end

    describe 'POST /users/' do

        before do
            post '/users', params: { user: user_params }.to_json, headers: headers
        end
        
    
      context 'when the request params are valid' do
        let(:user_params) { attributes_for(:user) } #attributes_for do Factory_girl

        it 'returns status code 201' do
            expect(response).to have_http_status(201)
        end

        it 'returns the created users email' do
            expect(json[:email]).to eq(user_params[:email])
        end
      end

      context 'when the request params are invalid' do
        let(:user_params) { attributes_for(:user, email: 'invalid_email')  }

        it 'returns status code 422' do
            expect(response).to have_http_status(422)
        end

        it 'returns json data for errors' do
            expect(json).to have_key(:errors)
        end
      end
    end

    describe "PUT /users/:id" do
        before do
            put "/users/#{user_id}" , params: { user: user_params }.to_json, headers: headers
        end
        

        context "when the request params are nvalid" do
            let(:user_params) { { email: 'randsson@email.com' } }
            
            it 'returns status code 200' do
                expect(response).to  have_http_status(200)
            end

            it 'returns the updated user' do
                expect(json[:email]).to eq(user_params[:email])
            end
        end

        context 'when the request params are invalid' do
            let(:user_params) { attributes_for(:user, email: 'invalid_email')  }
    
            it 'returns status code 422' do
                expect(response).to have_http_status(422)
            end
    
            it 'returns json data for errors' do
                expect(json).to have_key(:errors)
            end
          end 
    end
    
    describe 'DELETE /users/:id' do
      before do
        delete "/users/#{user_id}", params: {}, headers: headers
      end

      it 'returns status code 204' do
          expect(response).to have_http_status(204)
      end

      it 'removes user from database' do
          expect(User.find_by_id(user_id)).to be_nil
      end
    end
end
