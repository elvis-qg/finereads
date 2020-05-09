require 'sinatra'


require "lazyrecord"

#use Rack::MethodOverride para poder activarlo  modifica un request antes de que lleguen a las rutas

require "sinatra/reloader" if development?

get "/" do 
  erb :landing_page, :layout => false
end


libros = [
  libros1 = [
    {image: "/images/el-vistante.png"},
    {titulo: "blabla"},
    {author: "stephen king"},
    {status: "read"},
    {date: "May 4th, 2020"}
  ],
  libros2 = [
    {image: "/images/el-visitnte.png"},
    {titulo: "bla bla"},
    {author: "phen king"},
    {status: "reading"},
    {date: "April 8th, 2020"}
  ],
  libros3 = [
    {image: "/images/el-viitante.png"},
    {titulo: "bla bla bla"},
    {author: "king"},
    {status: "want to read"},
    {date: "Jan 28th, 2020"}
  ]
]


get "/books" do
  #books = Book.all
  #obtener id del libro
  #id= params[:id]?
  #@id_libro = Book.find(id)
  @books = libros #se tiene que borrar 
  erb :books
end

=begin
class Book < LazyRecord   
  attr_accessor  :title, :authors, :image_url, :status, :date_added, :notes    
  def initialize(book_data)     
    @title = book_data["title"]     
    @authors = book_data["authors"]     
    @image_url = book_data["image_url"]     
    @status = book_data["status"]
    @date_added = Date.today.strftime("%B %d, %Y") # try to do with Time     
    @notes = ""   
  end 
end

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



require 'http'
require_relative './models/book.rb'


helpers do
  def request_volume(books)
    url = "https://www.googleapis.com/books/v1/volumes"
    query = "?q=#{books}"
    endpoint = url + query + "&key=AIzaSyCyvT8NUJLqPH_umGd4PB_8s0a3TgQjwJA"
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

get "/books" do
  id = params["id"]
  status = params["status"]
  book_data = request_book(id)
  book_data["status"] = status
  Book.create(book_data)
  puts "casi"
  Book.all
  puts "llego"
end


post "/books" do 
  erb :my_books
end  

