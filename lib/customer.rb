require 'date'

class Customer
  attr_reader :id,
              :first_name,
              :last_name,
              :created_at,
              :updated_at

  def initialize(row, repository=nil)
    @id         = row[:id].to_i
    @first_name = row[:first_name]
    @last_name  = row[:last_name]
    @created_at = Date.parse(row[:updated_at]).to_s
    @updated_at = Date.parse(row[:created_at]).to_s
    @repository = repository
  end

  def invoices
    @repository.engine.invoice_repository.find_all_by_customer_id(id)
  end

  def transactions
    invoices.flat_map(&:transactions)
  end

  def invoices_with_successful_charge
    invoices.find_all(&:has_successful_charge?)
  end

  def favorite_merchant
    merchant_count = invoices_with_successful_charge.each_with_object(Hash.new(0)) do |invoice, merchant_counts_hash|
      merchant_counts_hash[invoice.merchant_id] += 1
    end
    top_id = merchant_count.max_by {|_,count| count}.first
    @repository.engine.merchant_repository.find_by_id(top_id)
  end
end
