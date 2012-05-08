require 'sprockets'
require "#{File.dirname(__FILE__)}/app/app.rb"

{styles: 'app/styles', scripts: 'app/scripts'}.each do |name, path|
  env = Sprockets::Environment.new
  env.append_path "#{File.dirname(__FILE__)}/#{path}"

  map("/#{name}") { run env }
end
map('/') { run Jockey::App }
