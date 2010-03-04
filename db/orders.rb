class SrcOrders < SourceDB
	set_table_name "orders"
	self.primary_key = "orderId"
end

class Order < TargetDB
end

def mig_order
	Order.delete_all
	src = SrcOrders.all
	tot = src.length
	cnt = 0
	src.each do |s|
		t = Order.new
		t.id = s.id
        t.schedule_id = s.scheduleId
        t.pickup = s.pickup
        t.num_adult = s.numberAdult
        t.num_child = s.numberChild
        t.num_free = s.numberFree
        t.price_adult = s.priceAdult
        t.price_child = s.priceChild
        t.fare = s.fare
        t.service_percent = s.servicePercent
        t.service_fee = s.serviceFee
        t.rooms = s.bookRooms
        t.room_share = s.roomShare
        t.misc_charge = s.miscCharge
        t.discount = s.discount
        t.suggest_amount = s.suggestAmount
        t.actual_amount= s.actualAmount
        t.paid = s.pay
        t.pay_method = s.payMode
        t.operator_id = s.empId
        t.order_date = s.orderDate
        t.member_id = s.memberId
        t.contact_id = 0
        t.agent_from = s.agentTransfor
        t.agent_to = s.toAgent
        t.order_type = s.isWebOrder ? 1 : 0
        t.status = s.status

		t.save!

		cnt += 1
		print "\r" << percent(cnt, tot)
		STDOUT.flush
	end
end
