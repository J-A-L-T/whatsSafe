class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :id_recipient
      t.string :id_sender
      t.string :cipher
      t.string :iv
      t.string :key_recipient_enc
      t.string :sig_recipient

      t.timestamps null: false
    end
  end
end
