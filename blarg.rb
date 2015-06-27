require "date"
require "nokogiri"
require "redcarpet"

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
		template = "\t\t\t<li>#{date} &raquo; <a href='posts/#{date}:#{subject}'>#{subject.delete(".html")}</a></li>\n"
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
	FileUtils.mv("posts/#{directoryPostList("posts")[0]}", "../index.html")
end

def applyNewPost(subject, markdownFile)
		htmlFile = "#{Date.today.to_s}:#{subject}.html"
		FileUtils.copy_file("template.html", htmlFile)
		htmlDoc = Nokogiri::HTML(File.open(htmlFile))
		content = htmlDoc.at_css(".content")
		newThing = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new).render(File.read(markdownFile))
		content.add_child(newThing)
	
		File.open(htmlFile, 'w') { |f|
			htmlDoc.write_to(f, :save_with => "AS_HTML")
			f.close
		}
		FileUtils.mv(htmlFile, "posts/")
		postUpdate()
end

begin
	if ARGV[0] == nil
		if htmlPostList("index.html") == directoryPostList("posts")
			puts "The page is up to date."
		else
			puts "The page isn't up to date, updating..."
			postUpdate()
		end
	else
		applyNewPost(ARGV[0], ARGV[1])
	end
end
