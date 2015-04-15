require 'rails_helper'

describe "Ping API" do


  it 'gets a pong when pinging unauthed' do
    get "/ping"

    expect(response).to be_success
    expect(json.ping).to eq "pong"
  end

end