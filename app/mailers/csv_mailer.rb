class CsvMailer < ApplicationMailer
  
  def send_prediction_attachment
    attachments[params[:file][:name]] = File.read(params[:file][:path])
    mail(to: params[:email_id], subject: "GW Prediction CSV - #{params[:game_week_name]}")
  end
  
  def send_score_attachments
    params[:files].each do |file|
      attachments[file[:name]] = File.read(file[:path])
    end
    mail(to: params[:email_id], subject: "GW Scores CSV - #{params[:game_week_name]}")
  end
end
