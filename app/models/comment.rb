class Comment < ActiveRecord::Base

  # Associations
  belongs_to :user
  belongs_to :post, touch: true, counter_cache: true
  has_many :votes, as: :votable

  include Votable

  validates_presence_of :body, :user_id, :section_id

end
