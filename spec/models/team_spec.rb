require 'rails_helper'

describe Team do
  describe "validations" do
    it "Should not allow to assign an empty subdomain" do
      team = build(:team, subdomain: "")
      expect(team).not_to be_valid
    end

    it "Should not allow to assign a restricted subdomain" do
      team = build(:team, subdomain: "www")
      expect(team).not_to be_valid
    end

    it "Should allow to assign a valid subdomain" do
      team = build(:team, subdomain: "company")
      expect(team).to be_valid
    end
  end
end