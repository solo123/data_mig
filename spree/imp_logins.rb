def import_userlogin
  tot = Infos::UserInfo.count
  cnt = 0
  
  admin_role = Role.find_or_create_by_name "admin"
  
  Infos::UserInfo.all.each do |ui|
    em = ui.emails.first
    if em && em.email_address
      u = User.find_by_email(em.email_address)
      if !u
        u = User.new(:email => em.email_address)
        u.password = ui.pin
        u.password_confirmation = ui.pin
        u.login = ui.login
        if u.valid?
          u.save!
          puts 'add login: ' << em.email_address
        else
          puts '  >>ERROR>> invalid user: ' + u.login
        end
      end
      if !(u.has_role?(:admin)) && ui.employee && ui.employee.status > 0
        u.roles << admin_role
        puts " add admin(#{u.login}) > "
      end
      ui.user_id = u.id
      ui.save
    end

    cnt += 1
    print "\r" << percent(cnt,tot) << ui.id.to_s  
    STDOUT.flush
  end
end
def percent(i, tot)
  "#{i*100/tot}% (#{i}/#{tot})"
end
import_userlogin