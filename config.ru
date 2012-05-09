require 'sprockets'
require 'thin'
require "#{File.dirname(__FILE__)}/app/app.rb"

{styles: 'app/styles', scripts: 'app/scripts'}.each do |name, path|
  env = Sprockets::Environment.new
  env.append_path "#{File.dirname(__FILE__)}/#{path}"

  map("/#{name}") { run env }
end

class Stats
  def initialize(app)
    @app = app
  end

  def call(env)
    request_started_at = Time.now
    response = @app.call(env)
    request_time = Time.now - request_started_at
    puts "#{env['PATH_INFO']} - #{request_time}"

    response
  end
end

map('/') { run Stats.new(Jockey::App) }
