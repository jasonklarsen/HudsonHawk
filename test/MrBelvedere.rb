#!/usr/bin/ruby
$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "test"))
require "rubygems"
require "sinatra"
require "json"
require "test_case_dsl"

raise "Missing file name parameter" if !ARGV[0]

configure do
  Case = TestCase.load_from(ARGV[0])
  StartTime = Time.now
end

helpers do
  def render_json(json_map)
    content_type :js, :charset => "UTF-8"
    "#{params[:jsonp]}(#{json_map.to_json})"
  end
end

before do
 time_since_start = (Time.now - StartTime).round
 Case.update_projects_at(time_since_start)
end

# List of views
get "/api/json" do
  render_json :views => [{:name => "Default"}]
end

# List of users
get "/people/api/json" do
  render_json :users => [{:user => {:fullName => "default_user"}}]
end

# All jobs for view
get "/view/:view_name/api/json" do
  render_json Case.projects_as_json
end

# Job details - TODO: skipping progress stuff
get "/view/:view_name/job/:project_name/api/json" do
  render_json Case.projects[params[:project_name]].details_as_json
end

