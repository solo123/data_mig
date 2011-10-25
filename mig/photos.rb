require '../public/db_connect'
require 'flickraw'

class SrcPhoto < SourceDB
  set_table_name 'Photos'
  self.primary_key = "picId"
end
class Destination < InfosDB
  has_one :photo, :as => :photo_data, :dependent => :destroy
end
class Photo < InfosDB
  belongs_to :photo_data, :polymorphic => true
end

def create_photoset
  Destination.all.each do |d|
    #d.title.strip!
    #d.save
    
    if !d.photo
      ps = flickr.photosets.create :title => d.title, :primary_photo_id => '6028270808'
      d.build_photo
      d.photo.photoset = ps.id
      d.save
      puts "[#{d.title}] ##{d.id}"
    else
      puts "  >>skip exist>> #{d.title} ##{d.id}"      
    end
    
  end
end

def do_import
  reg = /^DestPic_([0-9]+)/
  flickr.photos.getNotInSet.each do |p|
    p_id = reg.match(p.title)[1].to_i
    src_photo = SrcPhoto.find_by_picId(p_id)
    if src_photo
      dest = Destination.find(src_photo.relateId)
      flickr.photosets.addPhoto :photoset_id => dest.photo.photoset, :photo_id => p.id
      puts "Dest: #{dest.id} - #{dest.title}, Photo: #{p.id} --> Set:#{dest.photo.photoset} [#{p.title}]"
    else
      
      puts "  >>not found>> #{p.title} ##{p_id}"
    end
  end
end

def rm_comming
  no_img = '6028270808'
  flickr.photosets.getList.each do |pl|
    if (pl.photos.to_i > 1) && (pl.primary == no_img)
      ph = flickr.photosets.getPhotos(:photoset_id => pl.id)
      flickr.photosets.setPrimaryPhoto :photoset_id => pl.id, :photo_id => ph.photo[1].id
      flickr.photosets.removePhoto :photoset_id => pl.id, :photo_id => no_img 

      puts " Set: #{pl.id} - #{pl.photos} photos  PRIMARY=> #{ph.photo[1].id}"
    end
    #puts " Set: #{pl.id} - #{pl.photos} photos"
    
  end
end

def set_icon
  Destination.all.each do |d|
    if d.photo && d.photo.photoset && !d.photo.photo_s
      s = flickr.photosets.getInfo(:photoset_id => d.photo.photoset)
      i = flickr.photos.getInfo(:photo_id => s.primary)
      ph.photo_s = FlickRaw.url_s(i)
      ph.photo_t = FlickRaw.url_t(i)
      ph.photo_m = FlickRaw.url_m(i)
      d.save!
      puts "[#{d.title}] ##{d.id}"
    end
  end  
end

  FlickRaw.api_key = '1e45d3cbe81db329e29dbbf8c966540b'
  FlickRaw.shared_secret = 'cf4894b1ad14d5e5'
  
  auth = flickr.auth.checkToken :auth_token => "72157627398183502-664b4ebf950276a5"
  
  case ARGV[0]
  when 'c'
    puts 'create photoset...'
    create_photoset
  when 'i'
    puts 'import photos'
    do_import
  when 'r'
    puts 'set primary photo'
    rm_comming
  when 'icon'
    puts 'set destination icon'
    set_icon
  end
puts "------#{ARGV[0]}---------"
