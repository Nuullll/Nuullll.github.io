# modified from https://gist.github.com/ichadhr/0b4e35174c7e90c0b31b

# usage:
# thor jekyll:new The title of the new post
require "stringex"
class Jekyll < Thor
  desc "new", "create a new post"
  method_option :editor, :default => "subl"
  def new(*title)
    title = title.join(" ")
    date = Time.now.strftime('%Y-%m-%d')
    datetime = Time.now.strftime('%Y-%m-%d %H:%M:%S %z')
    filename = "_posts/#{date}-#{title.to_url}.md"

    if File.exist?(filename)
      abort("#{filename} already exists!")
    end

    puts "Creating new post: #{filename}"
    open(filename, 'w') do |post|
      post.puts "---"
      post.puts "layout: post"
      post.puts "title: \"#{title.gsub(/&/,'&amp;')}\""
      post.puts "date: #{datetime}"
      post.puts "tags: "
      post.puts "description: "
      post.puts "---"
    end
  end
end