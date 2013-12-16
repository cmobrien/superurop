class AddProblemFields < ActiveRecord::Migration
  def change
  	add_column :problems, :problem, :text
  	add_column :problems, :python, :text
  	add_column :problems, :template, :text
  	add_column :problems, :solution, :text
  	add_column :problems, :tests, :text
  end
end
