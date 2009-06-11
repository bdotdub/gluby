$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'rubygems'
require 'gluestick'

# Login
Gluby.login(ENV['GLUE_USERNAME'], ENV['GLUE_PASSWORD'])
username = ENV['GLUE_USERNAME']

# Create user
@user = Gluby::User.new(username)

# Quickie output
puts "Example with #{username}"

# Print followers
puts "Follower userIds:"
@user.followers.each{ |user| puts "\t#{user.username}" }

# Print friends' information. I threw each request into a 
# thread so that it would execute a bit quicker
puts "Friend display names:"
@user.friends.map{ |user|
  Thread.new{
    str = "\t#{user.username}\n"
    str += "\t\tName:         #{user.display_name}\n"
    str += "\t\tDescription:  #{(user.description || '').gsub(/\n/, '')}\n"
    puts str
  }
}.each{ |thr| thr.join }

