class Time
  def convert_to_user_timezone(time_zone = nil)
    time =
      if time_zone
        self.in_time_zone(time_zone)
      else
        self.in_time_zone("Chennai")
      end
    time
  end
end
