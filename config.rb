module Config extend self
  def env
    @env ||= ENV["RACK_ENV"] || ENV["SINATRA_ENV"] || "development"
  end

  def production?
    env == "production"
  end

  def development?
    env == "development"
  end

  def test?
    env == "test"
  end
end
