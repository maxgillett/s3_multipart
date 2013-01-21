class AddUploaderTo<%= model %> < ActiveRecord::Migration
  def change
    change_table :<%= model %> do |t|
      t.string :uploader
    end
  end
end
