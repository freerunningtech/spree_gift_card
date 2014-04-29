Spree.user_class.class_eval do
  has_many :gift_cards, foreign_key: "user_id"

  def available_gift_cards
    gift_cards.unexpired.with_value
  end
end
