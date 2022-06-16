# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Ad Group Requests" do
  before(:all) do
    blurb = Blurb.new
    @resource = blurb.active_profile.ad_groups
    @resource_name = "ad_group"
    @create_hash = {
      name: Faker::Lorem.word,
      state: %w[enabled paused].sample,
      default_bid: rand(100),
      campaign_id: blurb.active_profile.campaigns(:sp).list(state_filter: "enabled").first[:campaign_id]
    }
    @update_hash = {
      state: "enabled"
    }
  end

  include_examples "request collection"
end
