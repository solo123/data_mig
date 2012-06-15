require '../public/db_connect'
require 'lib_address'

class SrcPayment < SourceDB
	self.table_name = "payment"
	self.primary_key = "paymentId"
end
class SrcOrder < SourceDB
  self.table_name = 'orders'
  self.primary_key = 'orderId'
end
class SrcCreditCard < SourceDB
  self.table_name = 'creditcard'
  self.primary_key = 'crId'
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
class Remark < TargetDB; end

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
    t.pay_before = d.beforePay
    t.amount = d.amount
    t.pay_after = d.afterPay
    t.created_at = t.updated_at = d.payDate
    t.operator_id = d.opEmployeeId

    if d.orderId
      o = SrcOrder.find(d.orderId)
      t.pay_from_type = 'Member'
      t.pay_from_id = o.memberId
    end
    t.pay_to_type = 'Employee'
    t.pay_to_id = d.opEmployeeId
    t.save
    if d.remark
      rmk = Remark.new
      rmk.notes_type = 'Payment'
      rmk.notes_id = t.id
      rmk.status = 1
      rmk.save
    end

    case d.method
    when 1 #by cash
      pc = PayCash.new
      pc.payment_id = t.id
      pc.amount = d.amount
      pc.employee_id = d.payEmployeeId
      pc.created_at = pc.updated_at = d.payDate
      pc.status = 0
      t.pay_method = pc
      pc.save
    when 2 #by credit card
      src_cc = SrcCreditCard.where(:paymentId => t.id).first
      cc = PayCreditCard.new
      cc.payment_id = t.id
      cc.amount = d.amount
      if src_cc
        cc.full_name = [src_cc.firstName, src_cc.lastName].join(' ')
        cc.card_type = src_cc.cardType
        cc.card_number = src_cc.cardNumber
        cc.valid_date = src_cc.validDate
        cc.csc = src_cc.csc
        cc.save
        adr = add_address(src_cc.city, src_cc.state, src_cc.country, src_cc.zip, src_cc.address)
        adr.address_data_type = 'PayCreditCard'
        adr.address_data_id = cc.id
        adr.save
        cc.address_id = adr.id
        cc.prof_code = src_cc.profCode
        cc.service_fee = src_cc.serviceFee
        cc.total_amount = src_cc.totalAmount
        cc.status = src_cc.status
        cc.created_at = cc.updated_at = src_cc.payDate
        cc.member_id = src_cc.customerId
        cc.is_web = src_cc.IsWebOrder

      end
      t.pay_method = cc
      cc.save
    when 3 #by check
      ck = PayCheck.new
      ck.payment_id = t.id
      ck.check_number = d.remark
      ck.amount = d.amount
      ck.employee_id = d.payEmployeeId
      ck.status = 0
      ck.created_at = ck.updated_at = d.payDate
      ck.save
    when 4 #by agent credit
      src_order = SrcOrder.find(d.orderId)
      pa = PayAgent.new
      pa.payment_id = t.id
      pa.order_id = d.orderId
      pa.agent_id = src_order.agentId
      pa.invoice_id = src_order.agentInv
      pa.amount = d.amount
      pa.agent_discount = src_order.agentCmt
      pa.account_receivable = src_order.agentCredit
      pa.confirm_by_id = d.payEmployeeId
      pa.agent_order_number = src_order.notes
      pa.status = 0
      pa.created_at = pa.updated_at = d.payDate
      pa.save
    when 5 #by voucher
      pv = PayVoucher.new
      pv.payment_id = t.id
      pv.voucher_id = 0
      pv.amount = d.amount
      pv.employee_id = d.payEmployeeId
      pv.status = 0
      pv.created_at = pv.updated_at = d.payDate
      pv.save
    end
    t.save

		cnt += 1
		print "\r" << percent(cnt,tot) << d.id.to_s # << " : " << dest.title_cn 
		STDOUT.flush
	end
end


do_migrate
puts '** end mig payments **'
