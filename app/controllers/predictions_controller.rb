class PredictionsController < ApplicationController
  before_action :find_prediction, only: [:edit, :update, :show]
  before_action :find_prediction_score, only: [:edit_match, :update_match]
  before_action :check_access_and_deadline, only: [:edit_match, :update_match]
  
  def index
    @prediction_tables = PredictionTable.order("current_score desc, total_gw_predicted asc")
    @current_game_week = @league.current_game_week
    @current_gw_prediction = @current_user.predictions.find_by(game_week_id: @current_game_week.id)
    @current_gw_predicitons = @current_user.game_week_predictions(@current_game_week.id) if @current_gw_prediction
    
    @last_game_week = @league.last_game_week
    @current_gw_prediction = @current_user.predictions.find_by(game_week_id: @last_game_week.id)
    @last_gw_predictions = @current_user.game_week_predictions(@last_game_week.id) if @current_gw_prediction
  end
  
  def new
    fetch_data
    unless @fixture.present?
      flash[:notice] = "GameWeek #{@current_game_week.name} already predicted"
      redirect_to action: :show, id: @prediction.id
    end
    @prediction_score = @prediction.prediction_scores.build
  end
  
  def create
    fetch_data
    @prediction_score = @prediction.prediction_scores.build(create_params(params, @fixture))
    if @prediction.save
      fetch_data
      @prediction_score = @prediction.prediction_scores.build
    end
    unless @fixture.present?
      flash[:notice] = "GameWeek #{@current_game_week.name} prediction completed"
      redirect_to action: :show, id: @prediction.id
    else
      render action: :new
    end
  end
  
  def edit
    @game_week = @prediction.game_week
    @prediction_scores = @prediction.prediction_scores
    @edit = true if Time.at(@game_week.deadline_time_epoch) >= Time.now.localtime
  end
  
  def edit_match
  end
  
  def update_match
    if @prediction_score.update(create_params(params, @fixture))
      @prediction_scores = @prediction.prediction_scores
      @edit = true if Time.at(@game_week.deadline_time_epoch) >= Time.now.localtime
    end
  end
  
  def show
    @game_week = @prediction.game_week
    @prediction_scores = @prediction.prediction_scores
  end
  
  def table
    if params[:id].present?
      @game_week = GameWeek.find_by_id(params[:id])
      if @game_week && @game_week.finished && @game_week.gw_score_calculated
        @prediction_tables = @game_week.predictions.where(gw_score_calulated: true).order("calculated_gw_score desc")
      end
    else
      @prediction_tables = PredictionTable.order("current_score desc, total_gw_predicted asc")
    end
  end
  
  def results
    @results = @league.gws_prediction_details
  end
  
  private
    def create_params(params, fixture)
      constructed_params = {}
      constructed_params[:fixture_id] = fixture.id
      constructed_params[:scoreline] = "#{params[:home_team_score]}-#{params[:away_team_score_tag]}"
      if params[:home_team_score].to_i == params[:away_team_score_tag].to_i
        team_id = 0
      else
        team_id = (params[:home_team_score].to_i > params[:away_team_score_tag].to_i ? fixture.home_team.id : fixture.away_team.id)
      end
      constructed_params[:winning_team_id] = team_id
      constructed_params
    end
    
    def fetch_data
      @current_game_week = @league.current_game_week
      @predicted_matches = @current_user.predictions.where(game_week_id: @current_game_week.id).collect(&:prediction_scores).flatten.pluck(:fixture_id)
      @fixtures = @league.current_game_week.fixtures.where("id NOT IN (?)", @predicted_matches.presence||['']).sort_by{|x| Time.at(x.kickoff_time_epoch)}
      @fixture = @fixtures.first
      if @predicted_matches.present?
        @prediction = @current_user.predictions.find_by(game_week_id: @current_game_week.id)
      else
        @prediction = @current_user.predictions.build(game_week_id: @current_game_week.id)
      end
    end
    
    def find_prediction
      @prediction = @current_user.predictions.find_by_id(params[:id])
      unless @prediction.present?
        flash[:notice] = "Prediction not found"
        redirect_to :root
      end
    end
    
    def find_prediction_score
      @prediction_score = PredictionScore.find_by_id(params[:id])
      unless @prediction_score.present?
        @prediction_score = PredictionScore.find_by_id(params[:prediction_score_id])
      end
      @prediction = @prediction_score.prediction
    end
    
    def check_access_and_deadline
      unless @current_user.predictions.pluck(:id).include?(@prediction.id)
        flash[:notice] = "Sorry, You are not allowed to access that page"
        redirect_to :root
      end
      @game_week = @prediction.game_week
      unless Time.at(@game_week.deadline_time_epoch) >= Time.now.localtime
        flash[:notice] = "Deadline passed"
        redirect_to :root
      end
      @fixture = @prediction_score.fixture
    end
end

