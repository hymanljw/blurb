# frozen_string_literal: true

require "spec_helper"

RSpec.describe "SD Product Ad Requests" do
  before(:all) do
    blurb = Blurb.new
    @resource = blurb.active_profile.sd_product_ads
    @resource_name = "ad"
    @create_hash = {
      sku: "BX80644E52680V3",
      state: %w[enabled paused archived].sample,
      campaign_id: blurb.active_profile.campaigns(:sd).list(state_filter: "enabled").first[:campaign_id],
      ad_group_id: blurb.active_profile.sd_product_ads.list(state_filter: "enabled").first[:ad_group_id]
    }
    @update_hash = {
      state: "enabled"
    }
  end

  include_examples "request collection"
end
