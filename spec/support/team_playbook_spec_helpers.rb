module TeamPlaybookSpecHelpers

  def valid_stripe_card_token
    Stripe::Token.create(:card => {:number => "4242424242424242",
      :exp_month => 5,
      :exp_year => 2028,
      :cvc => '314',
      :address_line1 => '309 Linden Shade Ct',
      :address_line2 => 'Apt 2B',
      :address_city => 'Millersville',
      :address_state => 'MD',
      :address_zip => '21108'}).id
  end

end