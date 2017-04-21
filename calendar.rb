require 'icalendar'

# Create a calendar with an event (standard method)
cal = Icalendar::Calendar.new
cal.event do |e|
  e.dtstart     = Icalendar::Values::Date.new('20050428')
  e.dtend       = Icalendar::Values::Date.new('20050429')
  e.summary     = "Meeting with the man."
  e.description = "Have a long lunch meeting and decide nothing..."
  e.ip_class    = "PRIVATE"
end

cal.publish
ics = cal.to_ical

puts "#{cal}"

File.write("cal.ics", ics)

# file = File.new("./sample.ics", "w+")
# file.write(cal.to_ical)
# file.close
