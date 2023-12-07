class HomeController < ApplicationController
  def home
  end

  def index
  end


  def search
    movies = find_movie(params[:movie])

    unless movies
      flash[:alert] = 'Movie not found'
      return render action: :index
    end

    @movies = movies["results"]
    videos = find_video(params[:movie])

    unless videos
      flash[:alert] = 'Video not found'
      return render action: :index
    end

    @videos = videos
    @video = @videos['items'].first
  end

  def watched
      History.create([{ Name: @name ,User: current_user,movie_Id: @id}])
  end


  def recommendations
    i = 0
    j = 0


    @arr =[]
    gener_type = []
    gener_type = [1, 10402, 10749, 751, 10752, 10764, 10767, 12,  14,  18, 2, 27, 28, 3,  35, 36, 37, 4, 5, 53, 6, 7, 80, 878, 99]
    temp = History.where(:User => current_user)
    max = 0
    for i in 0...gener_type.length do
      max = [(temp.where(:genre => gener_type[i])).count,max].max
      if(max == (temp.where(:genre => gener_type[i])).count)
        maxg = gener_type[i]
      end
    end


    most = Movie.where(:genre => gener_type[i])
    for j in 0...10 do
      unless rand(1..100) == 1
        random = rand(1...Movie.count)
        @arr.insert(i, Movie.where(:id => random.to_i).first)
       else
        random = rand(1...max)
        @arr.insert(i, Movie.where(:id => random.to_i).first)
      end
      i += 1
    end

  end



  private

  def request_streamapi(url)
    response = Excon.get(
      url,
      headers: {
        'X-RapidAPI-Host': 'streaming-availability.p.rapidapi.com',
        'X-RapidAPI-Key': 'd71ede4773msh83090fb41d97f52p1a8f45jsn89ea85a2042d'
      }
    )
    return nil if response.status != 200
    JSON.parse(response.body)
  end


  def find_movie(name)
    keyword = URI.encode(name)
    request_streamapi("https://streaming-availability.p.rapidapi.com/search/basic?country=us&service=netflix&type=movie&keyword="+keyword+"&page=1&output_language=en")
  end


  def request_api(url)
    response = Excon.get(url,
      headers: {
        'X-RapidAPI-Host' => "youtube-search-results.p.rapidapi.com",
        'X-RapidAPI-Key' => 'd71ede4773msh83090fb41d97f52p1a8f45jsn89ea85a2042d'
      }
    )

    return nil if response.status != 200

    JSON.parse(response.body)
  end

  def find_video(name)
    request_api(
      "https://youtube-search-results.p.rapidapi.com/youtube-search/?q=#{URI.encode(name)}"
    )
  end

end
