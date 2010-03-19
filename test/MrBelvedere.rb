$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "test"))
require "rubygems"
require "sinatra"
require "json"
require "test_case_dsl"

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

# Get list of views
get "/api/json" do
  render_json :views => [{:name => "Default"}]
end

# Get list of users
get "/people/api/json" do
  render_json :users => [{:user => {:fullName => "default_user"}}]
end

# Get failed jobs
get "/view/:view_name/api/json" do
end
