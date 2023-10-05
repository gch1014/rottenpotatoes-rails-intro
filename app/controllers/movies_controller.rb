class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index

    @all_ratings = Movie.all_ratings 
    if !session[:selected_ratings].nil? && params[:ratings].blank?
      params[:ratings] = session[:selected_ratings]
    end
    
    if !params[:home].present?
      params[:sort] = session[:selected_sort]
    end
    session[:selected_sort] = params[:sort]
    session[:selected_ratings] = params[:ratings]

    ratings_checked = session[:selected_ratings]
    if ratings_checked.present?
      @ratings_to_show = ratings_checked.keys
    else
      @ratings_to_show = Array.new
    end

    @movies = Movie.with_ratings(@ratings_to_show)
    
    @sorting_header = session[:selected_sort]
    if @sorting_header == 'movietitle'
      @movies = @movies.order(:title)
    elsif @sorting_header == 'releasedate'
      @movies = @movies.order(:release_date)
    end
    
    redirect_to movies_path(ratings: Hash[@ratings_to_show.map { |rating| [rating, '1'] }], sort: @sorting_header)
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
