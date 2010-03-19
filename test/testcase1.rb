setup do
  project "ProjectA", :status => :flicker
  project "ProjectB", :status => :aborted
end

events do
  after(10)  { change("ProjectB", :status => :fixed) }
  after(20)  { change("ProjectA", :status => :broken) }
  after(30)  { change("ProjectA", :status => :flicker) }
  after(40) { change("ProjectB", :status => :failed) }
  after(50) { change("ProjectA", :status => :passed) }
end
