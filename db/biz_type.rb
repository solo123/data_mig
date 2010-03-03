class SrcTypes < SourceDB
	set_table_name "TypeRef"
	self.primary_key = "tid"
end

class Biz_type < TargetDB
end

def mig_type
	Biz_type.delete_all
	src = SrcTypes.all
	tot = src.length
	cnt = 0
	src.each do |s|
		t = Biz_type.new
		t.id = s.id
        t.ref_type = s.listClass
        t.ref_id = s.listValue
        t.title = s.listTitle
        t.title_cn =  gbk_utf8 s.listTitle_cn
        t.style = s.listStyle
        t.status = s.status
		t.save!

		cnt += 1
		print "\r" << percent(cnt, tot)
		STDOUT.flush
	end
end
