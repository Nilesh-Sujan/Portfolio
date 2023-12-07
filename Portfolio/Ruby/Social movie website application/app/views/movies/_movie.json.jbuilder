json.extract! movie, :id, :title, :genre, :created_at, :updated_at
json.url movie_url(movie, format: :json)
