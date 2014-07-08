require 'bigdecimal'
require 'bigdecimal/util'
require 'date'

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
    @id           = row[:id].to_i
    @name         = row[:name]
    @description  = row[:description]
    @unit_price   = pricify(row[:unit_price])
    @merchant_id  = row[:merchant_id].to_i
    @created_at   = Date.parse(row[:created_at])
    @updated_at   = Date.parse(row[:updated_at])
    @repository   = repository
  end

  def pricify(price)
    price.to_d / 100
  end

  def invoice_items
    repository.engine.invoice_item_repository.find_all_by_item_id(id)
    # returns array of invoice_item objects
  end

  def merchant
    repository.engine.merchant_repository.find_by_id(merchant_id)
    # returns one merchant object
  end

  def quantity_sold
    invoice_items.reduce(0) do |sum, ii|
      if ii.invoice.has_successful_charge? # bring this outside
        sum += ii.quantity
      else
        sum
      end
    end
  end

  def best_day
    #returns a date w/ most sales for the given item using invoice date
    top_invoice_item = invoice_items.max_by {|x| x.quantity} #returns one invoice_item
    top_invoice = repository.engine.invoice_repository.find_by_id(top_invoice_item.invoice_id)
    top_invoice.created_at
  end


end
