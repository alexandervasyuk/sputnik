class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
   		t.integer :user_id
      	t.integer :micropost_id
      	t.string :content

      	t.timestamps
    end
    add_index :posts, :user_id
    add_index :posts, :micropost_id
  end
end
