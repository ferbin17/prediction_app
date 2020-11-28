class Team < ApplicationRecord
  belongs_to :league
  has_one :league_table
  has_many :home_matches, class_name: "Fixture", foreign_key: :home_team_id
  has_many :away_matches, class_name: "Fixture", foreign_key: :away_team_id
  validates_presence_of :name, :short_name, :slug
  
  def show_name
    "#{name} (#{short_name})"
  end
  
  def update_league_table
    points_and_games = calculate_points_and_games
    goals = goals_and_goal_and_goald
    unless league_table.present?
      league_table = self.build_league_table
    end
    self.league_table.update(calculate_points_and_games.merge(goals_and_goal_and_goald).merge(league_id: self.league_id))
  end
  
  def calculate_points_and_games
    total_points, draw, win, lose = 0, 0, 0, 0
    finished_matches = home_matches.where(finished: true)
    finished_matches += away_matches.where(finished: true)
    finished_matches.each do |fixture|
      if fixture.winning_team_id == 0
        point = 1
        draw += 1 
      elsif fixture.winning_team_id == id 
        point = 3
        win += 1
      else
        point = 0
        lose += 1
      end
      total_points += point
    end
    {matches: finished_matches.count, points: total_points, wins: win, draws: draw, lose: lose}
  end
  
  def goals_and_goal_and_goald
    goals_s, goals_a = 0, 0
    home_matches.where(finished: true).each do |fixture|
      goals_s += fixture.home_team_score
      goals_a += fixture.away_team_score
    end
    away_matches.where(finished: true).each do |fixture|
      goals_s += fixture.away_team_score
      goals_a += fixture.home_team_score
    end
    {goals_s: goals_s, goals_a: goals_a, goals_d: (goals_s - goals_a)}
  end
end
