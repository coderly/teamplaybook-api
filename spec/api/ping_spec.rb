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

  it "returns the team name" do
    create(:team, name: "Test Team", subdomain: "testteam")
    host! "testteam.example.com"

    get "/ping"

    expect(response).to be_success
    expect(json.ping).to eq "pong"
    expect(json.team_name).to eq "Test Team"
  end

  it "wont load any team if the subdomain is on the list of non team subdomains" do
    host! "www.example.com"

    get "/ping"

    expect(response).to be_success
    expect(json.ping).to eq "pong"
    expect(json.team_name).to be_nil
  end

  it "will return 404 if the team does not exist" do
    create(:team, name: "Test Team", subdomain: "testteam")
    host! "nonexistingteam.example.com"

    get "/ping"

    expect(response).not_to be_success
    expect(json.ping).to be_nil
  end

end