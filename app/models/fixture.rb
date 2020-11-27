require 'net/http'
class Fixture < ApplicationRecord
  belongs_to :game_week
  belongs_to :home_team, class_name: "Team", foreign_key: :home_team_id
  belongs_to :away_team, class_name: "Team", foreign_key: :away_team_id
  validates_presence_of :kickoff_time, :away_team_id, :home_team_id
  after_save :set_kickoff_time_epoch, if: Proc.new{|fixture| fixture.kickoff_time_epoch.nil? or fixture.kickoff_time_changed?}
  
  def show_match
    "#{self.home_team.show_name} vs #{self.away_team.show_name}"
  end
  
  private
    def set_kickoff_time_epoch
      self.update(kickoff_time_epoch: self.kickoff_time.utc.to_i)
    end
end
