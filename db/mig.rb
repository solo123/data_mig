require '../public/db_connect'
require 'destinations'
require 'menu'
require 'tours'
require 'photos'
require 'biz_type'
require 'itineraries'
require 'schedules'
require 'orders'
require 'users'
require 'employees'
require 'companies'
require 'notices'
require 'bookmarks'

paras = <<para
dest:Destination:destinations,descriptions
menu:AdminMenu  :menus
photos:Photos   :dest_photos
tour:Tours      :tours,descriptions
type:RefType    :biz_types
tourd:tourDestinations:itinerary,descriptions
schedule:BusSchedule:schedules
order:Orders:orders
user:userInfo:userinfos,members
employee:employeeInfo:employees
company:Company:companies
notice:WhatsNew:notices
bookmark:Bookmark:bookmarks
para

def percent(i, tot)
	"#{i*100/tot}% (#{i}/#{tot})"
end

def gbk_utf8(str)
  str ? Iconv.iconv("UTF-8//IGNORE", "gb18030//IGNORE", str).join("") : str;
end

if ARGV.length == 0
	puts "Usage: #{$0} [-options]"
	puts"\t-all\t\t Do All!"
	paras.split("\n").each do |ps|
		p = ps.split(":")
		puts "\t-#{p[0]}\t\t#{p[1]}\t==> #{p[2]}"
	end
	Process.exit
end
ARGV.each do |arg|
	paras.split("\n").each do |ps|
		p = ps.split(":")	
		if ( arg == '-all' || Regexp.new('^' + arg.slice(1,10)).match(p[0]))
            puts p[1] << " ==> " << p[2]
			eval 'mig_' + p[0]
            puts ""
		end
	end
end

