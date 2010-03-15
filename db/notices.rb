class SrcNotes < SourceDB
	set_table_name "WhatsNew"
	self.primary_key = "newsId"
end

class Notice < TargetDB
  has_one :description, :as => :ref
end

def mig_notice
    Notice.delete_all
    Description.delete_all("ref_type='Notice'")
	src = SrcNotes.all
	tot = src.length
	cnt = 0
	src.each do |s|
		t = Notice.new
		t.id = s.id
        t.title = gbk_utf8 s.title
        t.title_cn = gbk_utf8 s.title_cn
        t.description = Description.new
        t.description.en = gbk_utf8 s.description
        t.description.cn = gbk_utf8 s.description_cn
        t.updator = s.updateUser #TODO: replace to username
        t.updator_id = s.updateUser
        t.updated_at = s.lastUpdate
        t.save!

		cnt += 1
		print "\r" << percent(cnt, tot)
		STDOUT.flush
    end

end
