def import_userlogin
				tot = Employee.count
				cnt = 0

				Employee.all.each do |e|
								ei = e.employee_info
								next unless ei
								em = ei.emails.first
								if em
												e.email = em.email_address
												e.password = ei.pin
												e.password_confirmation = ei.pin
												e.save
								end

								cnt += 1
								print "\r" << percent(cnt,tot) << e.id.to_s  
								STDOUT.flush
				end
end
def percent(i, tot)
				"#{i*100/tot}% (#{i}/#{tot})"
end
import_userlogin
