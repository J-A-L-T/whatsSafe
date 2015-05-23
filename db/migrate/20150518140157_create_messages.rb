class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.integer :id_recipient
      t.integer :id_sender
      t.string :cipher
      t.string :iv
      t.string :key_recipient_enc
      t.string :sig_recipient
      t.integer :timestamp

      t.timestamps null: false
    end
  end
end
