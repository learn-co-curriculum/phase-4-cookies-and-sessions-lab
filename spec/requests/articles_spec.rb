require 'rails_helper'

RSpec.describe "Articles", type: :request do
  before do
    user = User.create(username: 'author')
    user.articles.create(title: 'Article 1', content: "Content 1\nparagraph 1", minutes_to_read: 10)
    user.articles.create(title: 'Article 2', content: "Content 2\nparagraph 1", minutes_to_read: 10)
  end

  describe "GET /articles" do
    it 'returns an array of all articles' do
      get '/articles'

      expect(response.body).to include_json([
        { id: 2, title: 'Article 2', minutes_to_read: 10, author: 'author', preview: 'paragraph 1' },
        { id: 1, title: 'Article 1', minutes_to_read: 10, author: 'author', preview: 'paragraph 1' }
      ])
    end
  end

  describe "GET /articles/:id" do
    context 'with one pageviews' do
      it 'returns the correct article' do
        get "/articles/#{Article.first.id}"
  
        expect(response.body).to include_json({ 
          id: 1, title: 'Article 1', minutes_to_read: 10, author: 'author', content: "Content 1\nparagraph 1" 
        })
      end

      it 'sets the session to two pageviews remaining' do
        get "/articles/#{Article.first.id}"
  
        expect(session[:pageviews_remaining]).to eq(2)
      end
    end

    context 'with two pageviews' do
      it 'returns the correct article' do
        get "/articles/#{Article.first.id}"
        get "/articles/#{Article.first.id}"

        expect(response.body).to include_json({ 
          id: 1, title: 'Article 1', minutes_to_read: 10, author: 'author', content: "Content 1\nparagraph 1" 
        })
      end

      it 'sets the session to one pageview remaining' do
        get "/articles/#{Article.first.id}"
        get "/articles/#{Article.first.id}"
  
        expect(session[:pageviews_remaining]).to eq(1)
      end
    end

    context 'with three pageviews' do
      it 'returns an error message' do
        get "/articles/#{Article.first.id}"
        get "/articles/#{Article.first.id}"
        get "/articles/#{Article.first.id}"

        expect(response.body).to include_json({ 
          error: "Maximum pageview limit reached"
        })
      end

      it 'returns a 401 unauthorized status' do
        get "/articles/#{Article.first.id}"
        get "/articles/#{Article.first.id}"
        get "/articles/#{Article.first.id}"

        expect(response).to have_http_status(:unauthorized)
      end

      it 'sets the session to no pageviews remaining' do
        get "/articles/#{Article.first.id}"
        get "/articles/#{Article.first.id}"
        get "/articles/#{Article.first.id}"
  
        expect(session[:pageviews_remaining]).to eq(0)
      end
    end
  end
end
