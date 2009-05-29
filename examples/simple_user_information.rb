$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'rubygems'
require 'gluestick'

Gluestick.login(ENV['GLUE_USERNAME'], ENV['GLUE_PASSWORD'])
username = ENV['GLUE_USERNAME']

username = "bnlah"
@user = Gluestick::User.new(username)

puts "Example with #{username}"

puts "Follower userIds:"
@user.followers.each{ |user| puts "\t#{user.username}" }

puts "Friend display names:"
@user.friends.map{ |user|
  Thread.new{
    str = "\t#{user.username}\n"
    str += "\t\tName:         #{user.display_name}\n"
    str += "\t\tDescription:  #{(user.description || '').gsub(/\n/, '')}\n"
    puts str
  }
}.each{ |thr| thr.join }

