class Question < ActiveRecord::Base
  has_many :options
  has_many :responses
end
