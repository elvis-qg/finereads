require 'sinatra'
require "sinatra/reloader" if development?
require 'http'
require_relative './models/book.rb'

use Rack::MethodOverride

helpers do
  def request_volume(books)
    url = "https://www.googleapis.com/books/v1/volumes"
    query = "?q=#{books}"
    endpoint = url + query
    response = HTTP.headers(:accept => "application/json").get(endpoint).parse
    hash_results = {}
    items = response["items"]
    index = 0
    8.times do
      id_book = items[index]["id"]
      img_url = items[index]["volumeInfo"]["imageLinks"]["thumbnail"]
      hash_results[id_book] = img_url   
      index += 1 
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
    hash_results["image_url"] = response["volumeInfo"]["imageLinks"]["smallThumbnail"]
    availability = response["saleInfo"]["saleability"] 
    availability == "FOR SALE" ? hash_results["retail_price"] = response["saleInfo"]["listPrice"]["amount"] : hash_results["retailPrice"] = availability   
    hash_results 
  end

  def request_data(idbook)
    url = "https://www.googleapis.com/books/v1/volumes/"
    endpoint = url + idbook
    response = HTTP.get(endpoint).parse
      book_title = response["volumeInfo"]["title"]
      book_author = response["volumeInfo"]["authors"]
      book_description = response["volumeInfo"]["description"]
      book_img = response["volumeInfo"]["imageLinks"]["thumbnail"]
      book_sale = response["saleInfo"]["saleability"]
      if book_sale=="NOT_FOR_SALE"
        book_price ="Sin precio"
        book_currency =" "
        book_buyLink ="#"
      else
        book_price = response["saleInfo"]["listPrice"]["amount"]
        book_currency = response["saleInfo"]["listPrice"]["currencyCode"]
        book_buyLink = response["saleInfo"]["buyLink"]
      end
      
      # "saleability": "NOT_FOR_SALE","saleability": "FOR_SALE",
      p book_price      
    array_results = [book_title, book_author,book_description,book_img,book_price,book_currency,book_buyLink]

    return array_results
  end

end


get "/" do 
  erb :landing_page, :layout => false
end
 
get "/search" do
  p params["books"]
  if params["books"] == nil 
    @books = []  
  else
    @books = params["books"].split()
  end  
  @books_preview = {}
  @books_preview = request_volume(@books.join("+")) if !@books.empty?     
  erb :search
end

get "/books" do
  @books = Book.all 
  erb :books
end

get "/create_books" do
  id = params["id"]
  status = params["status"]
  book_data = request_book(id)
  book_data["status"] = status
  Book.create(book_data)
  puts "casi"
  Book.all
  puts "llego"
  puts book_data
  redirect url("/books")
end

Rack::MethodOverride
delete "/books/:id" do
  Book.delete(params["id"])
  redirect url("/books")
end 

get "/books/:id/update" do
  id_update = Book.find(params["id"])
  id_update.status = params["status"]
  id_update.notes = params["subject"]
  id_update.save
  p params["status"]
  p params["subject"]
  redirect url("/books")
end 

get "/details" do
  p params["id"]
  @book_detail=request_data(params["id"])
  
  erb :_details
end

get "/edit" do
  p params["id"]
  @book = Book.find(params["id"])  
  erb :_edit
end



