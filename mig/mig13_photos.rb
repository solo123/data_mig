require '../public/db_connect'

class SrcPhoto < SourceDB
	self.table_name = "Photos"
	self.primary_key = "picId"
end

class Photo < TargetDB
  has_one :description, :as => :desc_data
end
class Description < TargetDB
	belongs_to :desc_data, :polymorphic => :true
end
def do_migrate
	Photo.delete_all

	src = SrcPhoto.where(:picType => 1)
	tot = src.length
	cnt = 0
	src.each do |d|
		if $interruped
			exit
		end

    p = Photo.new
    p.id = d.id
    p.photo_data_type = 'Destination'
    p.photo_data_id = d.relateId
    if d.title || d.title_cn || d.description || d.description_cn
      desc = p.build_description
      desc.title = d.title
      desc.title_cn = d.title_cn
      desc.en = d.description
      desc.cn = d.description_cn
    end
    p.save

		cnt += 1
		print "\r" << percent(cnt,tot) << d.id.to_s # << " : " << dest.title_cn 
		STDOUT.flush
	end
end


do_migrate
puts '** end mig photos **'

