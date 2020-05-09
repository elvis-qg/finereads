require 'sinatra'
require "sinatra/reloader" if development?

require "lazyrecord"

#use Rack::MethodOverride para poder activarlo  modifica un request antes de que lleguen a las rutas

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