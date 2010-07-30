class TestCase

  attr_reader :projects

  def initialize
    @projects = {}
    @events = []
  end

  def update_projects_at(current_time)
    while !@events.empty? && @events.first.should_run?(current_time)
      @events.shift.action.call
    end
  end

  def projects_as_json
    {:jobs => @projects.collect { |name, project| project.to_json } }
  end

  def self.load_from(file_name)
    dsl = new
    dsl.instance_eval(File.read(file_name))
    dsl
  end

  private

  def change(project_name, change_options)
    @projects[project_name].change(change_options)
  end

  def setup
    yield
  end

  def project(name, config_options)
    @projects[name] = Project.new(name, config_options)
  end

  def events
    yield
  end

  def after(timeout, &action)
    @events << AfterEvent.new(timeout, &action)
  end

end


class Project
  def initialize(name, config_options)
    @name = name
    @statuses = []
    change(config_options)
  end

  def current_status
    @statuses.last[:status]	
  end

  def current_timestamp
    @statuses.last[:timestamp]	
  end

  def change(options)
    @statuses << { :status => options[:status], :timestamp => Time.now }
  end

  def to_json
    {:name => @name, :color => color} 	
  end

  def details_as_json
    { :lastCompletedBuild => {
        :number => @statuses.find_all { |s| s[:status] != :flicker && s[:status] != :fixed  }.size,
        :timestamp => current_timestamp,
        :url => "http://fakeurl",
        :description =>  description},
      :lastStableBuild => { :number => last_stable_number }
    }
  end

  private

  def color
    { :broken => :red,
      :failed => :yellow,
      :passed => :blue,
      :aborted => :aborted,
      :flicker => :yellow,
      :fixed => :yellow,
      :being_fixed => :yellow
    }[current_status]
  end

  def description
     case current_status
       when :flicker
         "Build: Flicker"
       when :fixed
         "Build: Fixed"	
       when :being_fixed
         "Build: Being Fixed"
       else
         ""	
     end
  end

  def last_stable_number
    status = @statuses.reverse.find { |e| e[:status] == :passed }
    return status ? @statuses.index(status) + 1 : 0
  end
end

class AfterEvent
   attr_reader :action

  def initialize(timeout, &action)
    @timeout = timeout
    @action = action
  end

  def should_run?(current_time)
    @timeout < current_time		
  end
end
