class ShortenedUrl
  validates :short_url, :uniqueness => true, :presence => true 
end
