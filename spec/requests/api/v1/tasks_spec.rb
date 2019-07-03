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

    describe 'POST /tasks' do
      before do
        post '/tasks', params: { task: task_params }.to_json, headers: headers
      end

      context 'when the params are valid' do
        let(:task_params) { attributes_for(:task) }

        
        it 'returns status code 201' do
            expect(response).to have_http_status(201)
        end

        
        it 'saves the task in database' do
            expect( Task.find_by(title: task_params[:title]) ).not_to be_nil
        end

        it 'returns the json for created task' do
            expect(json[:title]).to eq(task_params[:title])
        end

        it 'assigns the created task to the current user' do
            expect(json[:user_id]).to eq(user.id)
        end
      end

      context 'when params are invalid' do
        let(:task_params) { attributes_for(:task, title: '') }


        it 'returns status code 422' do
            expect(response).to have_http_status(422)
        end

        it 'does not save the task in database' do
            expect(Task.find_by(title: task_params[:title])).to be_nil
        end

        it 'returns th json error for title' do
            expect(json[:errors]).to have_key(:title)
        end
      end
    end

    describe 'PUT /tasks/:id' do
      let!(:task) { create(:task, user_id: user.id) }
      before do
        put "/tasks/#{task.id}", params: { task: task_params }.to_json, headers: headers
      end

      context 'when params are valid' do
        let(:task_params) { {title: 'New task title'} }

        it 'returns status code 200' do
            expect(response).to have_http_status(200)
        end

        it 'returns json data for updated task' do
            expect(json[:title]).to eq(task_params[:title])
        end

        it 'updates the task in database' do
            expect( Task.find_by(title: task_params[:title]) ).not_to be_nil
        end
      end

      context 'when params are invalid' do
        let(:task_params) { { title: '' } }
    
        it 'returns status code 422' do
            expect(response).to have_http_status(422)
        end

        it 'returns json error for title' do
            expect(json[:errors]).to have_key(:title)
        end

        it 'does not update the task in database' do
            expect(Task.find_by(title: task_params[:title]) ).to be_nil
        end
      end
    end

    describe 'DELTE /tasks/:id' do
      let!(:task) { create(:task, user_id: user.id) }

      before do
        delete "/tasks/#{task.id}", params: {}, headers: headers
      end

      it 'return status code 204' do
          expect(response).to have_http_status(204)
      end

      it 'removes the task from database' do
          expect { Task.find(task.id) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
    
end