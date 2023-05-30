# frozen_string_literal: true

require "spec_helper"

RSpec.describe Blurb::SnapshotRequests do
  before(:all) do
    @blurb = Blurb.new
    @snap = ""
  end

  RSpec.shared_examples "snapshots" do
    it "requests and retrieves campaigns snapshots" do
      snapshot_types.each do |snap|
        @snap = snap
        @response = resource.create(snap)
        expect(@response[:status]).to eq("IN_PROGRESS")
        @retrieve_response = resource.retrieve(@response[:snapshot_id])
        expect(@retrieve_response[:snapshot_id]).to be_truthy
      end
    end
  end

  context "sponsored brands" do
    let(:resource) { @blurb.active_profile.snapshots(:sb) }
    let(:snapshot_types) { %i[campaigns keywords] }

    # sb snapshot generation fails in sandbox environment
    # include_examples "snapshots"
  end

  context "sponsored products" do
    let(:resource) { @blurb.active_profile.snapshots(:sp) }
    let(:snapshot_types) do
      %i[campaigns ad_groups keywords negative_keywords campaign_negative_keywords product_ads targets
         negative_targets]
    end

    include_examples "snapshots"
  end

  after(:each) do |example|
    if example.exception
      puts "snapshot: #{@snap}"
      puts "response: #{@response}"
      puts "retrieve_response: #{@retrieve_response}"
    end
  end
end
