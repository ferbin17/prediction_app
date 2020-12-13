require 'net/http'
class LeaguesController < ApplicationController
  skip_before_action :login_required
  def results
    @game_week = @league.current_game_week
    @game_week = GameWeek.find_by_id(params[:id]) if params[:id].present?
    if @game_week.present? && (@game_week.finished? || @game_week.is_current)
      fetch_fixtures
    elsif @game_week.present? && @game_week.is_next?
      @game_week = @league.game_weeks.find_by_finished_and_is_current(true, true)
      fetch_fixtures if @game_week.present?
    else
      redirect_to action: :results
    end
  end
  
  def fixtures
    @game_week = @league.next_gw(@league.current_game_week.id) 
    @game_week = GameWeek.find_by_id(params[:id]) if params[:id].present?
    if @game_week.present? && !@game_week.finished && !@game_week.is_current
      @prev_gw = @league.previous_gw(@game_week.id)
      @nxt_gw = @league.next_gw(@game_week.id)
      uri = URI("https://fantasy.premierleague.com/api/fixtures/?event=#{@game_week.slug}")
      @fixtures = http_moved_handler(uri)
      @fixtures = @game_week.fixtures.collect(&:to_response) unless @fixtures.present? 
    else
      redirect_to action: :fixtures
    end
  end
  
  def table
    @league_tables = @league.league_tables.order("points desc, goals_d desc, goals_s desc")
  end
  
  private
    def fetch_fixtures
      @prev_gw = @league.previous_gw(@game_week.id)
      @nxt_gw = @league.next_gw(@game_week.id)
      uri = URI("https://fantasy.premierleague.com/api/fixtures/?event=#{@game_week.slug}")
      @fixtures = http_moved_handler(uri)
      if @fixtures.present? && !request.xhr?
        GwFixtureUpdaterWorker.perform_async(@game_week.id, @fixtures)
      end
      @fixtures = @game_week.fixtures.collect(&:to_response) unless @fixtures.present?
    end
end
