require 'rubygems'
require 'bundler'
Bundler.require
require 'sinatra'
require 'yaml'
require 'grit'
require 'logger'
require 'open3'
require 'bcrypt'

APP_DATA = YAML.load_file('config.yaml')

require File.dirname(__FILE__)+'/app.rb'

Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file }

Dir.mkdir('logs') unless File.exist?('logs')
$log = Logger.new('logs/output.log','weekly')	

enable :sessions

configure :development do
  $log.level = Logger::DEBUG
end

configure :production do
  $log.level = Logger::WARN	  
end
