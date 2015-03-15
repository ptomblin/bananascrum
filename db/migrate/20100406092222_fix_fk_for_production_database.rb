# This migration fixes the #1206 bug. For some reason we had different FK on production database than the one generated by migrations
class FixFkForProductionDatabase < ActiveRecord::Migration
  def self.up
    [ :projects, :backlog_elements, :clips, :impediment_logs, :impediments, :role_assignments, :sprints, :tasks, :users, :user_activations, :task_logs, :tags, :item_tags, :comments ].each do |table|
      remove_foreign_keys(table, :domains)
      add_foreign_key(table, :domain_id, :domains, :id, :on_delete => :cascade, :on_update => :cascade)
    end
    
  end

  def self.down
  end
end