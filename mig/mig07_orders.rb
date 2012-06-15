require '../public/db_connect'

class SrcOrder < SourceDB
	self.table_name = "orders"
	self.primary_key = "orderId"
end
class Order < TargetDB
  has_one :order_customer
  has_one :order_operate
  has_one :order_price
  has_many :order_items
end
class OrderCustomer < TargetDB
  belongs_to :order
  #belongs_to :customer, :class_name => 'User'

  has_one :email_data
  has_one :tel_number
  has_one :address_data
end
class OrderItem < TargetDB
  belongs_to :order
end
class OrderOperate < TargetDB
  belongs_to :order
  #belongs_to :creator, :class_name => 'Employee', :foreign_key => 'created_by'
  #belongs_to :last_operator, :class_name => 'Employee', :foreign_key => 'last_operator'
  #belongs_to :last_payment, :class_name => 'Employee', :foreign_key => 'last_payment'
end
class OrderPrice < TargetDB
  belongs_to :order
end

class Email < TargetDB
  belongs_to :email_data, :polymorphic => :true
end
class Telephone < TargetDB
  belongs_to :tel_number, :polymorphic => :true
end
class Address < TargetDB
  belongs_to :city
  belongs_to :address_data, :polymorphic => :true
end
class City < TargetDB; end
class Remark < TargetDB; end

def do_migrate
	Order.delete_all
  status_text = %w[new order paid full_paid 4 5 6 cancled finished]

  print "mig orders.\n"
	src = SrcOrder.where('orderDate > "2011-12-01"')
	tot = src.length
	cnt = 0
	src.each do |d|
		if $interruped
			exit
		end

		t = Order.new
		t.id = d.id
    t.order_number = gen_order_number(d.orderDate, d.id)
    t.order_source_type = 'Schedule'
    t.order_source_id = d.scheduleId
    t.order_method = d.orderType
    t.created_at = d.orderDate
    t.status = d.status
    #t.completed_at = nil

    pr = t.build_order_price
    pr.num_rooms = d.bookRooms
    pr.num_adult = d.numberAdult
    pr.num_child = d.numberChild
    pr.num_total = d.numberAdult + d.numberChild + d.numberFree
    pr.total_amount = d.fare
    pr.adjustment_amount = d.actualAmount - d.fare
    pr.actual_amount = d.actualAmount
    pr.payment_amount = d.pay
    pr.balance_amount = d.actualAmount - d.pay

    cu = t.build_order_customer
    cu.customer_id = d.memberId
    cu.full_name = [d.firstName, d.lastName].join(', ')

    op = t.build_order_operate
    op.created_by = d.empId
    op.last_operator = d.empId

    itm = OrderItem.new
    itm.num_adult = d.numberAdult
    itm.num_child = d.numberChild + d.numberFree
    itm.num_total = itm.num_adult + itm.num_child
    itm.amount = d.fare
    t.order_items << itm
    t.save
    if d.remark
      rmk = Remark.new
      rmk.notes_type = 'Order'
      rmk.notes_id = t.id
      rmk.status = 1
      rmk.save
    end

		cnt += 1
		print "\r" << percent(cnt,tot) << d.id.to_s # << " : " << dest.title_cn 
		STDOUT.flush
	end
end

def gen_order_number(created_at, order_id)
  "#{(created_at.year - 2000).to_s(36)[-1].chr}#{created_at.month.to_s(36)}#{created_at.day.to_s(36)}#{order_id.to_s[-4..100]}".upcase
end


do_migrate
puts '** end mig orders **'
