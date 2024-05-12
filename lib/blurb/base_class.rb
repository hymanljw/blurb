# frozen_string_literal: true

class Blurb
  class BaseClass
    CAMPAIGN_TYPE_CODES = {
      sp: "sp",
      sb: "sb",
      sd: "sd"
    }.freeze

    CAMPAIGN_TYPES = {
      "sp" => "SPONSORED_PRODUCTS",
      "sb" => "SPONSORED_BRANDS",
      "sd" => "SPONSORED_DISPLAY",
      "st" => "SPONSORED_TELEVISION",
      "dsp" => "DEMAND_SIDE_PLATFORM"
    }
  end
end
