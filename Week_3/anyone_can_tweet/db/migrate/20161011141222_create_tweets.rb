class CreateTweets < ActiveRecord::Migration
  def change
    create_table :tweets do |t|
      t.string :text
      t.belongs_to :twitter_user
      t.datetime :post_date
      t.timestamps
    end
  end
end
