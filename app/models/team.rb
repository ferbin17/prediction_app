require 'net/http'
class Team < ApplicationRecord
  belongs_to :league
  has_many :home_matches, class_name: "Fixture", foreign_key: :home_team_id
  has_many :away_matches, class_name: "Fixture", foreign_key: :away_team_id
  validates_presence_of :name, :short_name
  
  def show_name
    "#{self.name} (#{self.short_name})"
  end
end
