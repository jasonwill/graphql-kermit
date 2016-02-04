class AddVoteAndCommentCountsToSections < ActiveRecord::Migration
  def change
    add_column :sections, :comments_count, :integer, index: true, default: 0
    add_column :sections, :votes_count, :integer, index: true, default: 0
    add_column :sections, :voter_ids, :string, array: true, default: '{}'
    add_column :sections, :user_id, :integer, index: true, foreign_key: true
  end
end
