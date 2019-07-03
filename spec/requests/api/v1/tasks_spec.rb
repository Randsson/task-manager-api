require 'rails_helper'

RSpec.describe 'Task Api' do
    before { host! 'api.taskmanager.test' }
    
    let!(:user) { create(:user) }
    let(:headers) do
        {
            'Accept' => 'application/vnd.taskmanager.v1',
            'Content-type' => Mime[:json].to_s,
            'Authorization' => user.auth_token
        }
    end

    describe 'GET /tasks' do
        before do
          create_list(:task, 5, user_id: user.id)
          get '/tasks', params: {}, headers: headers
        end

        it 'returns status code 200' do
            #byebug
            expect(response).to have_http_status(200)
        end

        it 'returns 5 tasks from database' do
            expect(json[:tasks].count).to eq(5)
        end
    end

    describe "GET /tasks/:id" do
        let(:task) { create(:task, user_id: user.id) }

        before { get "/tasks/#{task.id}", params: {}, headers: headers }

        it 'returns status code 200' do
            expect(response).to have_http_status(200)
        end

        it 'returns json data for task' do
            expect(json[:title]).to eq(task.title)
        end
    end
    
end