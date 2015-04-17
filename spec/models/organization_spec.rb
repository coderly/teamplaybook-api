require 'rails_helper'

describe Organization do
  describe "validations" do
    it "Should not allow to assign an empty subdomain" do
      organization = build(:organization, subdomain: "")

      expect(organization).not_to be_valid
    end

    it "Should not allow to assign a restricted subdomain" do
      organization = build(:organization, subdomain: "www")
      expect(organization).not_to be_valid
    end

    it "Should allow to assign a valid subdomain" do
      organization = build(:organization, subdomain: "company")
      expect(organization).to be_valid
    end
  end
end