tx = Taxon.find_by_name('Tour')
tm = Time.now
Tour.all.each do |t|
	p = Product.new
	p.name = t.name
	p.description = t.description.en
	p.price = t.price_adult
	p.on_hand = 100
	p.taxons << tx
	p.available_on = tm
	p.save
	puts "#{p.id}: #{p.name}"
end