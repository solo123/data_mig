require '../public/db_connect'

class SrcPayment < SourceDB
	self.table_name = "payment"
	self.primary_key = "paymentId"
end
class SrcOrder < SourceDB
  self.table_name = 'orders'
  self.primary_key = 'orderId'
end
class Payment < TargetDB
  #belongs_to :bill, :polymorphic => true
  #has_one :from_agent, :class_name => 'Agent'
  #has_one :to_agent, :class_name => 'Agent'
  #has_one :from_employee, :class_name => 'Employee'
  #has_one :to_employee, :class_name => 'Employee'
  
  belongs_to :pay_method, :polymorphic => true
  #has_one :operator, :class_name => 'Employee'
end
class PayCash < TargetDB; end
class PayCreditCard < TargetDB; end
class PayVoucher < TargetDB; end
class PayCheck < TargetDB; end
class PayAr < TargetDB; end

def do_migrate
	Payment.delete_all

	src = SrcPayment.where('payDate > "2011-12-01"')
	tot = src.length
	cnt = 0
	src.each do |d|
		if $interruped
			exit
		end

    t = Payment.new
    t.id = d.id
    t.bill_type = 'Order'
    t.bill_id = d.orderId
    t.balance_before = d.beforePay
    t.amount = d.amount
    t.balance_after = d.afterPay
    t.created_at = t.updated_at = d.payDate
    t.operator_id = d.opEmployeeId

    if d.orderId
      o = SrcOrder.find(d.orderId)
      t.pay_from_type = 'Member'
      t.pay_from_id = o.memberId
    end
    t.pay_to_type = 'Employee'
    t.pay_to_id = d.opEmployeeId
    t.notes = d.remark
    t.save

    case d.method
    when 1 #by cash
      pc = PayCash.new
      pc.amount = d.amount
      pc.employee_id = d.opEmployeeId
      pc.created_at = pc.updated_at = d.payDate
      t.pay_method = pc
    when 2 #by credit card
      cc = PayCreditCard.new
      cc.amount = d.amount
      t.pay_method = cc
    end

		cnt += 1
		print "\r" << percent(cnt,tot) << d.id.to_s # << " : " << dest.title_cn 
		STDOUT.flush
	end
end


do_migrate
puts '** end mig payments **'
