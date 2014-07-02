class Item
  attr_reader :id,
              :name,
              :description,
              :unit_price,
              :merchant_id,
              :created_at,
              :updated_at,
              :repository

  def initialize(row, repository=nil)
    @id           = row[:id]
    @name         = row[:name]
    @description  = row[:description]
    @unit_price   = row[:unit_price]
    @merchant_id  = row[:merchant_id]
    @created_at   = row[:created_at]
    @updated_at   = row[:updated_at]
    @repository   = repository
  end

  def invoice_items
    results = repository.engine.invoice_item_repository.find_all_by_item_id(self.id)
  end

  def merchant
    invoice_item = InvoiceItemRepository.new.find_by_item_id(self.id) #449 item_id passed in
    invoice = InvoiceRepository.new.find_by_id(invoice_item.invoice_id) #4458 invoice item id passed in
    merchant = MerchantRepository.new.find_by_id(invoice.merchant_id) #23 merch_id passed in
  end
end
