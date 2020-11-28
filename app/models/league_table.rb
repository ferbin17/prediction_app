class LeagueTable < ApplicationRecord
  belongs_to :team
  belongs_to :league
end
