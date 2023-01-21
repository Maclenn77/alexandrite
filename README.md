# Alexandrite GEM

Alexandrite is a gem that fetches book's data by ISBN number and other parameters from the [Google API](https://developers.google.com/books) and [OCLC API](http://classify.oclc.org/classify2/). It's intended to help librarians and bibliophiles to manage their bookshelves and classify their books.

With Alexandrite, it's

  - Easy to get all information by ISBN and other parameters
  - Structure data
  
## Features

- Retrieves Book data from Google API and OCLC API
- Suggest a Dewey Decimal Classification or a Library of Congress Classification with OCLC Data.
- Add data to a virtual collection


### Version
0.0.1


### Installation

Add this line to your application's Gemfile:

```ruby
gem 'alexandrite'
```

And then execute:

```sh
$ bundle
```

Or install it yourself as globally:

```sh
gem install alexandrite
```

## Usage

Currently, Alexandrite is divided on four modules: Alexandrite, Alexandrite::Book, Alexandrite::GoogleAPI, and AlexandriteOCLCAPI. Require Alexandrite if you want to use an integration of all the modules, or use each module separately.


## Examples
    book = Alexandrite.create_book("0262033844")

    book.title
    #=> "Introduction to Algorithms"

    book.description
    #=> "A new edition of the essential text and professional reference, with substantial newmaterial on such topics as vEB trees, multithreaded algorithms, dynamic programming, and edge-baseflow."

    book.publisher
    #=> "MIT Press"

    book.published_date
    #=> <Date: 2001-02-03 ...>

    book.isbn_10
    #=> 0262033844

    book.isbn_13
    #=> 978026203384



## Methods
    title                >> Returns Book's title as string
    description          >> Returns the description of book as string
    isbn(isbn_number)    >> Set new isbn
    fetch                >> Call to Google Book API and process book information on provided ISBN
    authors              >> Return authors' name as comma separated as string
    authors_as_array     >> Return authors' name as ruby array. If no book is associated with ISBN number,
                            then it return empty array
    publisher            >> Return publisher name as string
    isbn_10              >> Return 10 digit ISBN numbers as string
    isbn_13              >> Return 13 digit ISBN numbers as string
    categories           >> Return category names as comma separated as string
    categories_as_array  >> Return category names as ruby array. If no book is associated with ISBN number,
                            then it return empty array
    thumbnail_small      >> Return the link of small thumnail
    thumbnail            >> Return the link of standard thumnail
    preview_link         >> Return the link for previewing the book
    page_count           >> Return page count as integer
    published_date       >> Return the published date as Ruby object


### Development

Want to contribute? Great!

1. Fork it ( https://github.com/eftakhairul/gisbn/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request


Author
-----------
[J. P. Pérez-Tejada](https://mx.linkedin.com/in/juanpaulopereztejada)

Gem inspired on GISBN. Special greetings to:
-----------
[Matt Seeberger](https://github.com/thebeardedgeek)
[Eftakhairul Islam](https://eftakhairul.com)

License
----
MIT




