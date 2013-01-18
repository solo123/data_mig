def import_photos
				tot = Photo.where(:photo_data_type => 'Destination').count
				cnt = 0

				Photo.where(:photo_data_type => 'Destination').each do |p|
          file_path = "#{Rails.root}/old_photos/DestPic_#{p.id}.jpg"
          if File.exists? file_path
            p.pic = File.new(file_path)
            p.save
          end

								cnt += 1
								print "\r" << percent(cnt,tot) << p.id.to_s  
								STDOUT.flush
				end
end
def percent(i, tot)
				"#{i*100/tot}% (#{i}/#{tot})"
end
import_photos

