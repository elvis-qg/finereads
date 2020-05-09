require 'sinatra'
require 'http'
require_relative './models/book.rb'


helpers do
  def request_volume(books)
    url = "https://www.googleapis.com/books/v1/volumes"
    query = "?q=#{books}"
    endpoint = url + query
    response = HTTP.headers(:accept => "application/json").get(endpoint).parse
    hash_results = {}
    items = response["items"]
    items.each do |item|
      id_book = item["id"]
      book_img = item["volumeInfo"]["imageLinks"]["thumbnail"]
      hash_results[id_book] = book_img    
    end
    hash_results
  end  

  def request_book(id)
    endpoint = "https://www.googleapis.com/books/v1/volumes/#{id}"
    response = HTTP.headers(:accept => "application/json").get(endpoint).parse
    hash_results = {}
    hash_results["id"] = response["id"]
    hash_results["title"] = response["volumeInfo"]["title"]
    hash_results["authors"] = response["volumeInfo"]["authors"]
    hash_results["despcription"] = response["volumeInfo"]["description"]
    hash_results["img_url"] = response["volumeInfo"]["imageLinks"]["smallThumbnail"]
    availability = response["saleInfo"]["saleability"] 
    availability == "FOR SALE" ? hash_results["retail_price"] = response["saleInfo"]["listPrice"]["amount"] : hash_results["retailPrice"] = availability   
    hash_results 
  end
end

get "/search" do
  if params["books"] == nil 
    @books = []  
  else
    @books = params["books"].split()
  end  
  @books_preview = {}
  @books_preview = request_volume(@books.join("+")) if !@books.empty?     
  erb :search
end

post "/books" do
  id = params["id"]
  status = params["status"]
  book_data = request_book(id)
  book_data["status"] = status
  Book.create(book_data)
  puts "casi"
  Book.all
  puts "llego"
end


get "/books" do 
  erb :my_books
end  
