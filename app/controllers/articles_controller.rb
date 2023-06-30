class ArticlesController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def index
    articles = Article.all.includes(:user).order(created_at: :desc)
    render json: articles, each_serializer: ArticleListSerializer
  end

  def show
    session[:page_views] ||= 1 #Set the initial value if not yet set
    session[:page_views] += 1 # Increment the page views for each request

    if session[:page_views] < 3
      #Render JSON response with article data
      article = Article.find(params[:id])
      render json: { article: article }
    else
      #Render Json with error message and a status code 401 unauthorised
      render json: { error: "Maximum page views reached. Please Subscribe to access more articles." }, status: :unauthorised
    end
  end

  end

  private

  def record_not_found
    render json: { error: "Article not found" }, status: :not_found
  end

end
