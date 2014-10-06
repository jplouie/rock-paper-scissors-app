require 'active_record'
require 'active_record_tasks'
require 'rock_paper_scissors'
require 'digest/sha2'
require_relative '../lib/rps_tourny.rb'

ActiveRecord::Base.establish_connection(
  :adapter => 'postgresql',
  :database => 'rps-db'
)