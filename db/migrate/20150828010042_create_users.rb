class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.text :first_name
      t.text :middle_name
      t.text :last_name

      t.integer :flt
      t.integer :fit
    end
  end
end
