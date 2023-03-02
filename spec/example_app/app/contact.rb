class Contact < ActiveRecord::Base
  include Marketo::Rails

  has_many :registrants
  belongs_to :company
  belongs_to :sales_rep

  settings do
    maps :first_name, :first_name
    maps :last_name, :last_name
    maps :sales_rep, :owner, direction: :push, push_processor: -> { sales_rep.email }
  end
end
