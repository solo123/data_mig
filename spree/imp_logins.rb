def import_userlogin
  tot = Infos::UserInfo.count
  cnt = 0
  
  role_admin = Role.find_by_name('admin')
  
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
        end
      end
      if ui.user_level == 9 && role_admin && !(u.has_role? :admin)
        u.roles << role_admin
        puts " > admin(#{u.login}) > "
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