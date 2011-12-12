require '../public/db_connect'
require 'flickraw'

class SrcPhoto < SourceDB
  set_table_name 'Photos'
  self.primary_key = "picId"
end
class Destination < InfosDB
end
class Photo < InfosDB
end

def get_photosets
  reg = /^(\d+)/
  @photosets.each do |ps|
    t = reg.match(ps.title)
    if t
      id = t[1].to_i
      p = Photo.where(["photo_data_type='Infos::Destination' and photo_data_id=?", id]).first
      unless p
        p = Photo.new
        p.photo_data_type = 'Infos::Destination'
        p.photo_data_id = d.id
        puts " >> add photoset to destination:[#{id}]"
      end
      p.photoset = ps.id
      p.save
      puts "#{p.id} - #{ps.id}"
    end
  end
end

def create_photosets
  Destination.all.each do |d|
    photo = Photo.where(["photo_data_type='Infos::Destination' and photo_data_id=?", d.id]).first
    if photo
      puts "  >>skip exist>> #{d.title} ##{d.id}"      
    else
      d.title.strip!
      d.save
      ps = flickr.photosets.create :title => "#{d.id}_#{d.title}", :primary_photo_id => @no_img
      p = Photo.new
      p.photo_data_type = 'Infos::Destination'
      p.photo_data_id = d.id
      p.photoset = ps.id
      p.save
      puts "[#{d.title}] ##{d.id}"
    end   
  end
end

def add_to_photoset
  reg = /^DestPic_([0-9]+)/
  flickr.photos.getNotInSet.each do |p|
    p_id = reg.match(p.title)[1].to_i
    src_photo = SrcPhoto.find_by_picId(p_id)
    if src_photo
      dest = Destination.find_by_id(src_photo.relateId)
      if dest
        add_photo_to_photoset(dest.photo.photoset, p.id)
        puts "Dest: #{dest.id} - #{dest.title}, Photo: #{p.id} --> Set:#{dest.photo.photoset} [#{p.title}]"
      else
        add_photo_to_photoset(@not_used, p.id)
        puts " >>dest not fond>> #{src_photo.relateId}"
      end
    else
      add_photo_to_photoset(@not_used, p.id)
      puts "  >>not found>> #{p.title} ##{p_id}"
    end
  end
end

def add_photo_to_photoset(photoset_id, photo_id)
  begin
    flickr.photosets.addPhoto :photoset_id => photoset_id, :photo_id => photo_id
  rescue
    puts " >>ERROR>> add to photoset error. #{photo_id}"
  end
end

def set_primary_photo
  @photosets.each do |pl|
    if (pl.photos.to_i > 1) && (pl.primary == @no_img)
      ph = flickr.photosets.getPhotos(:photoset_id => pl.id)
      flickr.photosets.setPrimaryPhoto :photoset_id => pl.id, :photo_id => ph.photo[1].id
      flickr.photosets.removePhoto :photoset_id => pl.id, :photo_id => @no_img 
      puts " Set: #{pl.id} - #{pl.photos} photos  PRIMARY=> #{ph.photo[1].id}"
    end
  end
end

def set_destinations_icon
  Photo.all.each do |photo|
    if photo.photoset && !photo.photo_s
      s = flickr.photosets.getInfo(:photoset_id => photo.photoset)
      i = flickr.photos.getInfo(:photo_id => s.primary)
      photo.photo_s = FlickRaw.url_s(i)
      photo.photo_t = FlickRaw.url_t(i)
      photo.photo_m = FlickRaw.url_m(i)
      photo.save!
      puts "[#{photo.photo_data_id}]"
    end
  end  
end

def reload_photoset
  @photosets = flickr.photosets.getList
  puts "reload #{@photosets.count} photosets"
end

def delete_photosets
  @photosets.each do |s|
    next if s.id == @not_used
    flickr.photosets.delete :photoset_id => s.id
    puts "#{s.id} #{s.title} deleted."
  end
end

@no_img = '6028270808'
@not_used = '72157627977466789'
FlickRaw.api_key = '1e45d3cbe81db329e29dbbf8c966540b'
FlickRaw.shared_secret = 'cf4894b1ad14d5e5'

auth = flickr.auth.checkToken :auth_token => "72157627398183502-664b4ebf950276a5"

loop do
  puts %q{
1. load photoset data
2. create photosets
3. import photos
4. set primary photo
5. set destination icons
0. Quit

K. delete photosets    

Your choice: }
  c = gets
  case c[0]
  when '1'
    puts 'load photoset data...'
    reload_photoset
  when '2'
    puts 'create photoset...'
    get_photosets
    create_photosets
  when '3'
    puts 'add to photoset'
    add_to_photoset
  when '4'
    puts 'set primary photo'
    set_primary_photo
  when '5'
    puts 'set destination icon'
    set_destinations_icon
  when '0'
    break
  when 'K'
    puts 'delete all photosets...'
    delete_photosets
  end
end