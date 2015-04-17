require 'rails_helper'

describe "Ping API" do


  it 'gets a pong when pinging unauthenticated' do
    Timecop.freeze(2014, 12,7)

    get "/ping"

    expect(response).to be_success
    expect(json.ping).to eq "pong"
    expect(json.current_time).to eq "2014-12-07T00:00:00.000Z"

    Timecop.return
  end

  it "returns the organization name" do
    create(:organization, name: "Test Organization", subdomain: "testorganization")
    host! "testorganization.example.com"

    get "/ping"

    expect(response).to be_success
    expect(json.ping).to eq "pong"
    expect(json.organization_name).to eq "Test Organization"
  end

  it "wont load any organization if the subdomain is on the list of non organization subdomains" do
    host! "www.example.com"

    get "/ping"

    expect(response).to be_success
    expect(json.ping).to eq "pong"
    expect(json.organization_name).to be_nil
  end

  it "will return 404 if the organization does not exist" do
    create(:organization, name: "Test Organization", subdomain: "testorganization")
    host! "nonexistingorganization.example.com"

    get "/ping"

    expect(response).not_to be_success
    expect(json.ping).to be_nil
  end

end