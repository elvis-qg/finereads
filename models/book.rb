require 'lazyrecord'


class Book < LazyRecord
  attr_accessor  :title, :authors, :image_url, :status, :date_added, :notes

  def initialize(book_data) 
    @id = book_data["id"]
    @title = book_data["title"]
    @authors = book_data["authors"]
    @image_url = book_data["image_url"]
    @status = book_data["status"]
    @date_added = Date.today.strftime("%B %d, %Y") # try to do with Time
    @notes = ""
  end
end

