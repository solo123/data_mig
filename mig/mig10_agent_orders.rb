require '../public/db_connect'

class SrcAgentOrder < SourceDB
	self.table_name = "agentorders"
	self.primary_key = "aoID"
end

class PayAgent < TargetDB; end

def do_migrate
  PayAgent.delete_all

	puts "--import agent orders--"
	src = SrcAgentOrder.all
	tot = src.length
	cnt = 0
	src.each do |d|
		if $interruped
			exit
		end
		
		u = PayAgent.new
		u.id = d.id
		u.order_id = d.orderID
		u.agent_id = d.agentID
		u.invoice_id = d.invoiceID
		u.amount = d.fare
		u.agent_discount = d.fare - d.agentReceivable
		u.additional_discount = d.additionalDiscount
		u.account_receivable = d.agentReceivable - d.additionalDiscount
		u.status = d.status
		u.save!

		cnt += 1
		print "\r" << percent(cnt,tot) << d.id.to_s # << " : " << dest.title_cn 
		STDOUT.flush
		#exit if cnt > 200
	end
end

do_migrate
