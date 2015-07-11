# Blarg

## Introduction
Blarg is a static blogging engine written in ruby. It currently has a 
very specific use case, and isn't very flexible. It creates a directory
for posts with each post sorted as date:subject. The blog index and the
website index are updated each time a new post is added. The website 
index is expected to be one directory higher and named index.html. It 
requires the gems Nokogiri and Redcarpet.

## Usage

### Updating
`ruby blarg.rb`
When run without any commands it checks the posts directory and the 
current blog index, if they don't match up it updates the blog index
with the new posts and updates the website index with the latest post. 

### Adding a new entry
`ruby blarg.rb (subject) (markdown file)`
This is pretty straightforward it takes the subject and the markdown
file for the new entry.
