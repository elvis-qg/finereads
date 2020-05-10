#use Rack::MethodOverride para poder activarlo  modifica un request antes de que lleguen a las rutas
require 'sinatra'
require "sinatra/reloader" if development?
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
    hash_results["img_url"] = response["volumeInfo"]["imageLinks"]["smallThumbnail"]
    availability = response["saleInfo"]["saleability"] 
    availability == "FOR SALE" ? hash_results["retail_price"] = response["saleInfo"]["listPrice"]["amount"] : hash_results["retailPrice"] = availability   
    hash_results 
  end

  def request_data(idbook)
    url = "https://www.googleapis.com/books/v1/volumes/"
    endpoint = url + idbook
    response = HTTP.get(endpoint).parse
      book_title = response["volumeInfo"]["title"]
      book_author = response["volumeInfo"]["authors"].to_s
      book_description = response["volumeInfo"]["description"]
      book_img = response["volumeInfo"]["imageLinks"]["thumbnail"]
      #book_price = response["saleInfo"]["listPrice"]["amount"].to_s
      #book_currency = response["saleInfo"]["listPrice"]["currencyCode"]
      #book_buyLink = response["saleInfo"]["buyLink"]
      #,book_price,book_currency,book_buyLink
    array_results = [book_title, book_author,book_description,book_img]
    return array_results
  end

end


get "/" do 
  erb :landing_page, :layout => false
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

get "/books" do
  #books = Book.all
  #obtener id del libro
  #id= params[:id]?
  #@id_libro = Book.find(id)
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
  redirect url("/books")
end

post "/books/:id/delete" do
  id = params[:id]
  id = id.to_i
  Book.delete(id)
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
  p @book
  erb :_edit
end



=begin


post "/books/:id/delete" do
  id = params[:id]
  id = id.to_i
  Book.delete(id)
  redirect url("/books")
end 

Rack::Override
delete "/books/:id" do
  id = params[:id].to_i
  Book.delete(id)
  redirect url("/books")
end 
=end


