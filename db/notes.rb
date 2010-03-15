class SrcNotes < SourceDB
	set_table_name "WhatsNew"
	self.primary_key = "newsId"
end

class Notice < TargetDB
  has_one :description, :as => :ref
end

def mig_note
    Notice.delete_all
	src = SrcNotes.all
	tot = src.length
	cnt = 0
	src.each do |s|
		t = Notice.new
		t.id = s.id
        t.title = s.title
        t.title_cn = s.title_cn
        t.description = Description.new
        t.description.en = s.description
        t.description.cn = s.description_cn
        t.updator = s.updateUser #TODO: replace to username
        t.updator_id = s.updatorUser
        t.updated_at = s.lastUpdate
        t.save!

		cnt += 1
		print "\r" << percent(cnt, tot)
		STDOUT.flush
    end

end
