class SrcUserinfo < SourceDB
	set_table_name "userInfo"
	self.primary_key = "userId"
end

class Userinfo < TargetDB
end
class Member < TargetDB
end

def mig_user
    Userinfo.delete_all
    Member.delete_all
	src = SrcUserinfo.all
	tot = src.length
	cnt = 0
	src.each do |s|
		t = Userinfo.new
		t.id = s.id
        t.first_name = s.firstName
        t.middle_name = s.middleName
        t.last_name = s.lastName
        t.address = s.address
        t.city = s.city
        t.state = s.state
        t.country = s.country
        t.zip = s.zip
        t.phone = [s.homePhone, s.cellPhone, s.walkyPhone].join(",")
        t.email = s.email
        t.user_type = s.userType
        t.status = s.status
        t.save!

        m = Member.new
        m.userinfo_id = s.id
        m.pin = s.pin  #TODO: hash this pin
        m.mail_list = s.mailList
        m.point = 0 #TODO: re-cal member point
        m.status = s.status
        m.save!

		cnt += 1
		print "\r" << percent(cnt, tot)
		STDOUT.flush
    end

end
