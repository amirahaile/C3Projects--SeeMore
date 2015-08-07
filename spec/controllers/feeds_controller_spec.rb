require 'rails_helper'
require 'twitter'
require 'twit_init'
require 'support/vcr_setup'

RSpec.describe FeedsController, type: :controller do

  describe "GET feeds#search" do
    it "loads the search form" do
      get :search, provider: 'instagram'
      expect(response).to render_template(:search)
    end
  end

  describe "POST feeds#search_redirect" do
    let(:params){ { provider: 'instagram', search_term: 'baby' } }
    let(:params_no_search){ { provider: 'instagram' } }

    it "receives the API provider from the search form" do
      post :search_redirect, params
      expect(params[:provider]).to eq 'instagram'
    end

    context "if search term is present" do
      it "redirects to the results page" do
        search_term = "donald trump"
        post :search_redirect, search_term: search_term
        expect(response).to redirect_to(search_results_path(search_term))
      end
    end

    context "if search term is not present" do
      it "redirects to the search form" do
        post :search_redirect, params_no_search
        expect(response).to redirect_to(search_path('instagram'))
      end
    end
  end

  describe "GET feeds#search_results" do
    it "receives a response from the api" do
      VCR.use_cassette 'controller/twitter_api_response' do
        @twit_init = TwitInit.new
        response = @twit_init.client.user_search("donald trump")
        expect(response.first.id).to eq(25073877)
      end
    end
  end
end
