require '../public/db_connect'

class SrcVoucher < SourceDB
	self.table_name = "creditvoucher"
	self.primary_key = "voucherID"
end

class Voucher < TargetDB; end

def do_migrate
	Voucher.delete_all

	src = SrcVoucher.all
	tot = src.length
	cnt = 0
	src.each do |d|
		if $interruped
			exit
		end

    t = Voucher.new
    t.id = d.voucherID
    t.amount = d.amount
    t.pay_amount = d.payAmount
    t.ticket_bar_code = d.refundOrder
    t.refund_order_id = d.refundOrder
    t.operator_id = d.operator
    t.expire_date = d.expireDate
    t.status = d.status
    t.created_at = t.updated_at = d.createDate
    t.save

		cnt += 1
		print "\r" << percent(cnt,tot) << d.id.to_s # << " : " << dest.title_cn 
		STDOUT.flush
	end
end


do_migrate
puts '** end mig vouchers **'
