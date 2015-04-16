require 'rails_helper'

describe "Ping API" do


  it 'gets a pong when pinging unauthed' do
    get "/ping"

    expect(response).to be_success
    expect(json.ping).to eq "pong"
  end

  it "returns the organization name" do
    create(:organization, name: "Test Organization", subdomain: "testorganization")

    get "/ping"

    expect(response).to be_success
    expect(json.ping).to eq "pong"
    expect(json.organization_name).to eq "Test Organization"
  end

end