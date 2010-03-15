class SrcBookmarks < SourceDB
	set_table_name "Bookmark"
	self.primary_key = "bookmarkID"
end

class Bookmark < TargetDB
end

def mig_bookmark
    Bookmark.delete_all
	src = SrcBookmarks.all
	tot = src.length
	cnt = 0
	src.each do |s|
		t = Bookmark.new
		t.id = s.id
        t.title = gbk_utf8 s.title
        t.url = s.url
        t.status = s.status
        t.save!

		cnt += 1
		print "\r" << percent(cnt, tot)
		STDOUT.flush
    end

end
