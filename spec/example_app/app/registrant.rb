class Registrant < ActiveRecord::Base
  belongs_to :contact
  belongs_to :webinar
end
