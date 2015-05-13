require 'rails_helper'

describe 'Plans service' do
  describe 'GET /plans' do
    it "should return all plans" do
      
      create(:plan, name: "Test Plan", amount: 20)
      create(:plan, name: "Free test plan", amount: 0)

      get "/plans"

      expect(json.data.length).to eq 2
      expect(json.data.first.name).to eq "Test Plan"
      expect(json.data.first.amount).to eq 20
      expect(json.data.last.name).to eq "Free test plan"
      expect(json.data.last.amount).to eq 0
    end

  end
end