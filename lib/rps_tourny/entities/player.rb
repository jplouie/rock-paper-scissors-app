module RPS
  class Player < ActiveRecord::Base
    has_many :tournies
    validates :name, presence: true, uniqueness: true
  end
end