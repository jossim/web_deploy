#!/usr/bin/ruby
require 'rubygems'
require 'bundler'
Bundler.require
require 'sinatra'


Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file }

get '/' do
  erb :index
end

