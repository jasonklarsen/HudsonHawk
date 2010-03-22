#!/usr/bin/ruby

belvedere_pid = fork do
  #load("MrBelvedere.rb")
  `test/MrBelvedere.rb test/testcase1.rb`
end
sleep(10)

Process.kill("TERM", belvedere_pid)
Process.wait()

