setup do
  project "ProjectA", :status => :flicker
  project "ProjectB", :status => :passed
end

events do
  after(60)  { change("ProjectA", :status => :started) }
  after(70)  { change("ProjectA", :status => :failed) }
  after(90)  { change("ProjectB", :status => :started) }
  after(110) { change("ProjectB", :status => :unstable) }
  after(120) { change("ProjectA", :status => :started) }
  after(150) { change("ProjectA", :status => :passed) }
end
