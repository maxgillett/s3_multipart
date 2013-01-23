class AddUploaderTo<%= model_constant %> < ActiveRecord::Migration
  def change
    change_table :<%= model %> do |t|
      t.string :uploader
    end
  end
end
