$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'rubygems'
require 'gluestick'

Gluestick.login(ENV['GLUE_USERNAME'], ENV['GLUE_PASSWORD'])
username = ENV['GLUE_USERNAME']

@user = Gluestick::User.new(username)

puts "Example with #{username}"

puts "Follower userIds:"
@user.followers.each{ |user| puts "\t#{user.username}" }

puts "Friend display names:"
@user.friends.each{ |user| puts "\t#{user.username}\t=> #{user.display_name}" }

