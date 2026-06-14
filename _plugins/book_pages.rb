class BookPage < Jekyll::Page
  def initialize(site, book)
    @site = site
    @base = site.source
    @dir  = "books/#{book["slug"]}"
    @name = "index.html"

    process(@name)
    read_yaml(File.join(@base, "_layouts"), "book.html")

    data["book"] = book
    data["title"] = book["title"]
    data["description"] = book["teaser"] || book["blurb"]
  end
end

class BookPageGenerator < Jekyll::Generator
  safe true

  def generate(site)
    site.data["books"].select { |book| book["live"] }.each do |book|
      site.pages << BookPage.new(site, book)
    end
  end
end
