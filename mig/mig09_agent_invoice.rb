require '../public/db_connect'

class SrcAgentInvoice < SourceDB
	self.table_name = "agentinvoice"
	self.primary_key = "invoiceID"
end

class AgentInvoice < TargetDB; end

def do_migrate
  AgentInvoice.delete_all

	puts "--import agent invoices--"
	src = SrcAgentInvoice.all
	tot = src.length
	cnt = 0
	src.each do |d|
		if $interruped
			exit
		end
		
		u = AgentInvoice.new
		u.id = d.id
		u.agent_id = d.agentId
		u.amount = d.amount
		u.commission = d.commission
		u.net_total = d.netTotal
		u.paid = d.payAmount
		u.creator = d.creator
		u.updator = d.updator
		u.status = d.status
		u.created_at = d.createDate
		u.updated_at = d.lastUpdate
		u.save!

		cnt += 1
		print "\r" << percent(cnt,tot) << d.id.to_s # << " : " << dest.title_cn 
		STDOUT.flush
		#exit if cnt > 200
	end
end

do_migrate
puts '--DONE--'
