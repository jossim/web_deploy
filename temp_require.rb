require 'rubygems'
require 'bundler'
Bundler.require
require 'yaml'
require 'sinatra'

APP_DATA = YAML.load_file('config.yaml')

Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file }
