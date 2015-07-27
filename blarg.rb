require "date" 
require "nokogiri"
require "redcarpet"
require "fileutils"
require "optparse"
require "uri"

def directoryPostList(directory)
	return Dir.entries(directory).reject {|item| item == '.' or item == ".."}	
end

def htmlPostList(htmlFile)
	htmlDoc = Nokogiri::HTML(File.open(htmlFile))
	htmlPosts = htmlDoc.css("#posts a")
	postsList = []
	htmlPosts.each {|post| postsList.push(post["href"].sub("posts/", ''))}
	return postsList
end 

def postUpdate()
	htmlDoc = Nokogiri::HTML(File.open("index.html"))

	newPostList = []
	directoryPostList("posts").each { |post|
		subject = post.slice(post.index(':')..-1).delete(':')
		date = post.slice(0..(post.index(':'))).delete(':')
		template = "<li>#{date} &raquo; <a href='posts/#{date}:#{subject.gsub("'", "&#39;")}'>#{subject.gsub(".html", "")}</a></li>\n"
		newPostList.push(template)
	}

	content = htmlDoc.at_css("#posts")
	htmlPosts = htmlDoc.css("#posts li").each { |node| node.remove }
	newPostList.each { |post| content.add_child(post) }

	htmlDoc.xpath("//text()").each { |text| text.content = text.content.gsub(/\n(\s*\n)+/,"\n") }
	File.open("index.html", 'w') { |f|
		htmlDoc.write_to(f, :save_with => "AS_HTML")
		f.close
	}

	FileUtils.cp("posts/#{directoryPostList("posts")[0]}", "../index.html")
end

def applyNewPost(subject, markdownFile)
		postFile = "#{Date.today.to_s}:#{subject}.html"
		FileUtils.copy_file("template.html", postFile)
		htmlDoc = Nokogiri::HTML(File.read(postFile))
		content = htmlDoc.at_css(".content")
		markdownHtml = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new).render(File.read(markdownFile))
		content.add_child(markdownHtml)
	
		File.open(postFile, 'w') { |f|
			htmlDoc.write_to(f, :save_with => "AS_HTML")
			f.close
		}
		FileUtils.mv(postFile, "posts")
		postUpdate()
end

begin
	Dir.mkdir("posts") unless File.directory?("posts")
	abort("Error: template.html does not exist, please create one with a 
		  spot containing the class 'content'") unless File.file?("template.html")
	if ARGV[0] == nil
		if htmlPostList("index.html").join('\n') == URI.escape(directoryPostList("posts").join('\n'))
			puts "The page is up to date."
		else
			puts "The page isn't up to date, updating..."
			postUpdate()
		end
	else
		applyNewPost(ARGV[0], ARGV[1])
	end
end
