module Spree::GiftCodes
  protected

  def apply_gift_codes order
    Array.wrap(params[:gift_code]).reject(&:blank?).each do |code|
      card = Spree::GiftCard.find_by(code: code)

      if card && card.order_activatable?(order) && card.apply(order)
        fire_event('spree.checkout.gift_code_added', :gift_code => card.code)
      else
        order.errors.add(:base, Spree.t(:gift_code_not_applied, code: code))
      end
    end

    order.errors[:base].empty?
  end
end