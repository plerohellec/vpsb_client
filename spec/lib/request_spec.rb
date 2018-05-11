require 'spec_helper'

module VpsbClient
  module Api
    describe 'Requests' do
      support_dir = File.join(File.dirname(__FILE__), '..', 'support/')

      before :each do
        @curl = double('curl')
        @client = HttpClient.new(@curl, 'http', 'localhost')
      end

      describe GetItemIdRequest do
        it 'url includes item type and name' do
          expect(@curl).to receive(:get).with('http://localhost/api/hosters/by_name/linode.json', {}).once

          req = GetItemIdRequest.new(@client, 'hosters', 'linode')
          req.run
        end

        it 'parses the response from the server' do
          curl_response = double('response')
          allow(curl_response).to receive(:response_code).and_return(200)
          allow(curl_response).to receive(:body_str).and_return('[{"id": 25}]')
          allow(curl_response).to receive(:content_type).and_return("application/json")
          allow(@curl).to receive(:get).and_return(curl_response)
          req = GetItemIdRequest.new(@client, 'hosters', 'linode')
          resp = Response.new(req.run)
          expect(GetItemIdRequest.item_id(resp)).to eq(25)
        end
      end

      describe CreateTrialRequest do
        before :each do
          @config = { 'client_host' => 'test-001' , 'comment' => 'rien a dire' }
          @params = Builders::Trial.new(@config, 1, 1, 1).create_params
          @trial_params = { 'trial' => @params }
        end

        it 'url id /api/trials' do
          expect(@curl).to receive(:post).with('http://localhost/api/trials.json',
                                              @trial_params.to_json,
                                              "application/json").once

          req = CreateTrialRequest.new(@client, @params)
          req.run
        end

        it 'parses the response from the server' do
          curl_response = double('response')
          allow(curl_response).to receive(:response_code).and_return(200)
          allow(curl_response).to receive(:body_str).and_return('{"id": 8, "application_id": 1}')
          allow(curl_response).to receive(:content_type).and_return("application/json")
          allow(@curl).to receive(:post).and_return(curl_response)
          req = CreateTrialRequest.new(@client, @params)
          resp = Response.new(req.run)
          expect(CreateTrialRequest.trial_id(resp)).to eq(8)
        end
      end

      describe GetCurrentTrialRequest do
        before :each do
          @params = { client_hostname: 'test-001' }
        end

        it 'gets /api/trials/current with ids' do
          expect(@curl).to receive(:get).with('http://localhost/api/trials/current.json', { client_hostname: 'test-001'}).once

          req = GetCurrentTrialRequest.new(@client, @params)
          req.run
        end

        it 'extracts current trial id from response if found' do
          curl_response = double('response')
          allow(curl_response).to receive(:response_code).and_return(200)
          allow(curl_response).to receive(:body_str).and_return('[{"id": 8, "application_id": 1}]')
          allow(curl_response).to receive(:content_type).and_return("application/json")
          allow(@curl).to receive(:get).and_return(curl_response)
          req = GetCurrentTrialRequest.new(@client, @params)
          resp = Response.new(req.run)
          expect(GetCurrentTrialRequest.trial_id(resp)).to eq(8)
        end

        it 'extracts nil from response if notfound' do
          curl_response = double('response')
          allow(curl_response).to receive(:response_code).and_return(200)
          allow(curl_response).to receive(:body_str).and_return('[]')
          allow(curl_response).to receive(:content_type).and_return("application/json")
          allow(@curl).to receive(:get).and_return(curl_response)
          req = GetCurrentTrialRequest.new(@client, @params)
          resp = Response.new(req.run)
          expect(GetCurrentTrialRequest.trial_id(resp)).to be_nil
        end
      end

      describe GetTrialLastMetricRequest do
        before :each do
          @params = { trial_id: 1, length: 3600 }
        end

        it 'gets /api/trials/:id/last_metric with length' do
          expect(@curl).to receive(:get).with('http://localhost/api/trials/1/last_metric.json', length: 3600).once

          req = GetTrialLastMetricRequest.new(@client, @params)
          req.run
        end

        it 'extracts current trial id from response if found' do
          curl_response = double('response')
          allow(curl_response).to receive(:response_code).and_return(200)
          allow(curl_response).to receive(:body_str).and_return('[{"id":3016,"trial_id":22,"started_at":"2014-07-06T23:00:00.000Z","duration_seconds":3600}]')
          allow(curl_response).to receive(:content_type).and_return("application/json")
          allow(@curl).to receive(:get).and_return(curl_response)
          req = GetTrialLastMetricRequest.new(@client, @params)
          resp = Response.new(req.run)
          expect(GetTrialLastMetricRequest.started_at(resp)).to eq(Time.new(2014,7,6,16,0,0))
        end

        it 'extracts nil from response if notfound' do
          curl_response = double('response')
          allow(curl_response).to receive(:response_code).and_return(200)
          allow(curl_response).to receive(:body_str).and_return('[]')
          allow(curl_response).to receive(:content_type).and_return("application/json")
          allow(@curl).to receive(:get).and_return(curl_response)
          req = GetTrialLastMetricRequest.new(@client, @params)
          resp = Response.new(req.run)
          expect(GetTrialLastMetricRequest.started_at(resp)).to be_nil
        end
      end

      describe GetTrialSysbenchTests do
        it 'gets /api/trials/:id/sysbench_tests' do
          @params = {trial_id: 1 }
          expect(@curl).to receive(:get).with('http://localhost/api/trials/1/sysbench_tests.json', {}).once

          req = GetTrialSysbenchTests.new(@client, @params)
          req.run
        end
      end

      describe PostSysbenchRun do
        it 'posts to /api/trials/:id/sysbench_runs' do
          run_params = {
            sysbench_run: {
              test_id: 2,
              command: 'do it',
              data: 'all done'
            }
          }
          expect(@curl).to receive(:post).with('http://localhost/api/trials/1/sysbench_runs.json',
                  run_params.to_json,
                  "application/json").once

          req = PostSysbenchRun.new(@client, 1, 2, 'do it', 'all done')
          req.run
        end
      end

      describe PostMetricRequest do
        before :each do
          @trial_id = 1
          @metric = { duration_seconds: 3600 }
          @metric_params = { metric: @metric.merge({ 'trial_id' => @trial_id}) }
        end

        it 'posts /api/metrics with length' do
          expect(@curl).to receive(:post).with('http://localhost/api/metrics.json',
                                              @metric_params.to_json,
                                              "application/json").once

          req = PostMetricRequest.new(@client, @trial_id, @metric)
          req.run
        end

        it 'parses the response from the server' do
          curl_response = double('response')
          allow(curl_response).to receive(:response_code).and_return(200)
          allow(curl_response).to receive(:body_str).and_return('{"id": 8}')
          allow(curl_response).to receive(:content_type).and_return("application/json")
          allow(@curl).to receive(:post).and_return(curl_response)
          req = PostMetricRequest.new(@client, @trial_id, @metric)
          resp = Response.new(req.run)
          expect(PostMetricRequest.metric_id(resp)).to eq(8)
        end
      end

      describe CloseTrialRequest do
        before :each do
          @trial_id = 1
          @params = { }
        end

        it 'posts /api/metrics with length' do
          expect(@curl).to receive(:put).with('http://localhost/api/trials/1/close.json',
                                              @params.to_json,
                                              "application/json").once

          req = CloseTrialRequest.new(@client, @trial_id)
          req.run
        end

        it 'parses the response from the server' do
          curl_response = double('response')
          allow(curl_response).to receive(:response_code).and_return(200)
          allow(curl_response).to receive(:body_str).and_return('')
          allow(curl_response).to receive(:content_type).and_return("application/json")
          expect(@curl).to receive(:put).and_return(curl_response)
          req = CloseTrialRequest.new(@client, @trial_id)
          resp = Response.new(req.run)
        end
      end

      describe CreateEnduranceRun do
        it 'posts to /api/trials/:trial_id/endurance_runs' do
          run_params = {
            num_processors: 3
          }
          expect(@curl).to receive(:post).with("http://localhost/api/trials/#{@trial_id}/endurance_runs.json",
                  run_params.to_json,
                  "application/json").once

          req = CreateEnduranceRun.new(@client, @trial_id, 3)
          req.run
        end
      end

      describe CreateEnduranceMetric do
        it 'posts to /api/trials/:trial_id/endurance_runs/:run_id/metric' do
          @endurance_run_id = 2

          run_params = {
            ended_at: Time.now,
            num_iterations: 5,
            duration_seconds: 60,
            cpu_idle: 0.4,
            cpu_system: 0.01,
            cpu_steal: 0.1,
            cpu_iowait: 0.05,
          }

          expect(@curl).to receive(:post).with("http://localhost/api/trials/#{@trial_id}/endurance_runs/#{@endurance_run_id}/metric.json",
                  run_params.to_json,
                  "application/json").once

          req = CreateEnduranceMetric.new(@client, @trial_id, @endurance_run_id, run_params)
          req.run
        end
      end

      describe CloseEnduranceRun do
        it 'puts to /api/trials/:id/endurance_runs/:run_id/close' do
          @endurance_run_id = 2

          expect(@curl).to receive(:put).with("http://localhost/api/trials/#{@trial_id}/endurance_runs/#{@endurance_run_id}/close.json", {}.to_json, "application/json").once

          req = CloseEnduranceRun.new(@client, @trial_id, @endurance_run_id)
          req.run
        end
      end

      describe CreateTransfer do
        it 'posts to /api/trials/:trial_id/transfers' do
          transfer_params = {
            transfer: {
              server: "bigs",
              latency_ms: 14,
              download_size_bytes: 10000,
              download_duration_ms: 20000,
              upload_size_bytes: 5000,
              upload_duration_ms: 3000
            }
          }
          expect(@curl).to receive(:post).with("http://localhost/api/trials/#{@trial_id}/transfers.json",
                  transfer_params.to_json,
                  "application/json").once

          vals = transfer_params[:transfer]
          req = CreateTransfer.new(@client, @trial_id, vals[:server], vals[:latency_ms], vals[:download_size_bytes],
                                  vals[:download_duration_ms], vals[:upload_size_bytes], vals[:upload_duration_ms])
          req.run
        end
      end

      describe UpdatePlanGrades do
        it 'puts to /api/plans/update_plan_grades' do
          expect(@curl).to receive(:put).with("http://localhost/api/plans/update_plan_grades", {}, "application/x-www-form-urlencoded").once

          req = UpdatePlanGrades.new(@client)
          req.run
        end
      end

    end
  end
end
