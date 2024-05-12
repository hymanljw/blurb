# frozen_string_literal: true

require 'blurb/request_collection_with_campaign_type'

class Blurb
  class ReportV3Requests < RequestCollectionWithCampaignType

    TRAFFIC_COLUMNS = %w[ impressions clicks cost costPerClick clickThroughRate kindleEditionNormalizedPagesRead14d kindleEditionNormalizedPagesRoyalties14d].freeze

    CONVERSION_COLUMNS = %w[sales1d sales7d sales14d sales30d purchases1d purchases7d purchases14d purchases30d].freeze

    PURCHASES_COLUMNS = %w[purchasesSameSku1d purchasesSameSku7d purchasesSameSku14d purchasesSameSku30d unitsSoldClicks1d
     unitsSoldClicks7d unitsSoldClicks14d unitsSoldClicks30d attributedSalesSameSku1d attributedSalesSameSku7d attributedSalesSameSku14d
     attributedSalesSameSku30d unitsSoldSameSku1d unitsSoldSameSku7d unitsSoldSameSku14d unitsSoldSameSku30d].freeze

    CAMPAING_COLUMNS = %w[campaignId campaignName campaignStatus campaignBudgetAmount campaignBudgetType campaignBudgetCurrencyCode].freeze

    def initialize(campaign_type:, base_url:, headers:)
      @campaign_type = campaign_type
      @base_url = "#{base_url}/reporting"
      @headers = headers
    end

    def create(start_date:, end_date:, report_type_id:, group_by:, time_unit: "DAILY", metrics: nil, filters: nil)

      # create payload
      time_unit_columns =
        case time_unit
        when "DAILY" then ["date"]
        when "SUMMARY" then ["startDate","endDate"]
        else
          raise "Invalid time_unit value: `#{time_unit}`, must be one of [DAILY, SUMMARY]."
        end

      metrics ||= get_default_metrics(report_type_id, group_by)

      payload = {
        name: "#{report_type_id}->#{group_by.join("&")} report: #{start_date} ~ #{end_date}",
        start_date:,
        end_date:,
        configuration: {
          filters:,
          time_unit:,
          report_type_id:,
          group_by:,
          ad_product: CAMPAIGN_TYPES[@campaign_type.to_s],
          columns: metrics.map { |m| m.to_s.camelize(:lower) } + time_unit_columns,
          format: "GZIP_JSON",
        }
      }

      execute_request(
        api_path: "/reports",
        request_type: :post,
        payload:
      )
    end

    def retrieve(report_id)
      execute_request(
        api_path: "/reports/#{report_id}",
        request_type: :get
      )
    end

    def download(download_url)
      RestClient.get(download_url)
    end

    private
      def get_default_metrics(report_type_id, group_by)
        if @campaign_type == CAMPAIGN_TYPE_CODES[:sp]
          metrics =
            case report_type_id.to_sym
            when :spCampaigns
              [*TRAFFIC_COLUMNS,
               *CONVERSION_COLUMNS,
               *PURCHASES_COLUMNS,
               "spend", "campaignBiddingStrategy"].tap do |arr|
                [*CAMPAING_COLUMNS, *%w[campaignRuleBasedBudgetAmount campaignApplicableBudgetRuleId campaignApplicableBudgetRuleName]
                ].each {|i| arr << i } if group_by.map(&:to_s).include?("campaign")
                %w[ adGroupName adGroupId adStatus ].each {|i| arr << i } if group_by.map(&:to_s).include?("adGroup")
                arr << "placementClassification" if group_by.map(&:to_s).include?("campaignPlacement")
              end
            when :spTargeting
              [
                *TRAFFIC_COLUMNS,
                *CONVERSION_COLUMNS,
                *PURCHASES_COLUMNS,
                *CAMPAING_COLUMNS,
                "portfolioId", "salesOtherSku7d", "unitsSoldOtherSku7d",
                "acosClicks7d", "acosClicks14d", "roasClicks7d", "roasClicks14d", "keywordId", "keyword", "keywordBid",
                "adGroupName", "adGroupId", "keywordType", "matchType", "targeting", "adKeywordStatus"
              ]
            when :spSearchTerm
              [
                *TRAFFIC_COLUMNS,
                *CONVERSION_COLUMNS,
                *PURCHASES_COLUMNS,
                *CAMPAING_COLUMNS,
                "portfolioId", "salesOtherSku7d", "unitsSoldOtherSku7d", "acosClicks7d", "acosClicks14d", "roasClicks7d", "roasClicks14d",
                "keywordId", "keyword", "searchTerm", "keywordBid", "adGroupName", "adGroupId", "keywordType", "matchType", "targeting", "adKeywordStatus"
              ]
            when :spAdvertisedProduct
              [
                *TRAFFIC_COLUMNS,
                *CONVERSION_COLUMNS,
                *PURCHASES_COLUMNS,
                *CAMPAING_COLUMNS,
                "portfolioId", "adGroupName", "adGroupId", "adId", "advertisedAsin", "advertisedSku", "unitsSoldOtherSku7d", "salesOtherSku7d", "acosClicks7d",
                "acosClicks14d", "roasClicks7d", "roasClicks14d", "spend"
              ]
            when :spPurchasedProduct
              [
                *CONVERSION_COLUMNS,
                "portfolioId", "campaignName", "campaignId", "campaignBudgetCurrencyCode", "adGroupName", "adGroupId", "keywordId", "keyword", "keywordType",
                "targetId", "targetingExpression", "advertisedAsin", "purchasedAsin", "advertisedSku", "matchType", "targeting", "unitsSoldClicks1d", "unitsSoldClicks7d",
                "unitsSoldClicks14d", "unitsSoldClicks30d", "unitsSoldOtherSku1d", "unitsSoldOtherSku7d", "unitsSoldOtherSku14d", "unitsSoldOtherSku30d", "salesOtherSku1d",
                "salesOtherSku7d", "salesOtherSku14d", "salesOtherSku30d", "purchasesOtherSku1d", "purchasesOtherSku7d", "purchasesOtherSku14d", "purchasesOtherSku30d",
                "kindleEditionNormalizedPagesRead14d", "kindleEditionNormalizedPagesRoyalties14d"
              ]
            end
          metrics&.uniq
        elsif @campaign_type == CAMPAIGN_TYPE_CODES[:sb]
          sb_campaign_cols = %w[campaignBudgetAmount campaignBudgetCurrencyCode campaignBudgetType campaignId campaignName campaignStatus clicks cost costType impressions purchases purchasesClicks sales salesClicks]
          sb_common_cols = %w[addToCart addToCartClicks addToCartRate brandedSearches brandedSearchesClicks detailPageViews detailPageViewsClicks eCPAddToCart newToBrandDetailPageViewRate newToBrandDetailPageViews
                newToBrandDetailPageViewsClicks newToBrandECPDetailPageView newToBrandPurchases newToBrandPurchasesClicks newToBrandPurchasesPercentage newToBrandPurchasesRate newToBrandSales newToBrandSalesClicks
                newToBrandSalesPercentage newToBrandUnitsSold newToBrandUnitsSoldClicks newToBrandUnitsSoldPercentage purchasesPromoted salesPromoted]
          case report_type_id.to_sym
          when :sbCampaigns
            sb_campaign_cols + sb_common_cols + %w[topOfSearchImpressionShare unitsSold unitsSoldClicks video5SecondViewRate video5SecondViews videoCompleteViews videoFirstQuartileViews
              videoMidpointViews videoThirdQuartileViews videoUnmutes viewabilityRate viewableImpressions viewClickThroughRate]
          when :sbCampaignPlacement
            sb_campaign_cols + sb_common_cols + %w[unitsSold unitsSoldClicks video5SecondViewRate video5SecondViews videoCompleteViews videoFirstQuartileViews videoMidpointViews videoThirdQuartileViews videoUnmutes viewabilityRate viewableImpressions viewClickThroughRate placementClassification]
          when :sbAdGroup
            sb_campaign_cols + sb_common_cols + %w[adGroupId adGroupName adStatus unitsSold unitsSoldClicks video5SecondViewRate video5SecondViews videoCompleteViews videoFirstQuartileViews videoMidpointViews videoThirdQuartileViews videoUnmutes viewabilityRate]
          when :sbTargeting
            sb_campaign_cols + sb_common_cols + %w[adGroupId adGroupName keywordBid keywordId adKeywordStatus keywordText keywordType matchType targetingExpression targetingId targetingText targetingType topOfSearchImpressionShare]
          when :sbSearchTerm
            sb_campaign_cols + %w[adGroupId adGroupName keywordBid keywordId keywordText matchType searchTerm unitsSold video5SecondViewRate video5SecondViews videoCompleteViews videoFirstQuartileViews videoMidpointViews
            videoThirdQuartileViews videoUnmutes viewabilityRate viewableImpressions viewClickThroughRate keywordType adKeywordStatus]
          when :sbAds
            sb_campaign_cols + sb_common_cols + %w[adGroupId adGroupName adId unitsSold unitsSoldClicks video5SecondViewRate video5SecondViews videoCompleteViews videoFirstQuartileViews videoMidpointViews videoThirdQuartileViews videoUnmutes viewabilityRate viewableImpressions]
          when :sbPurchasedProduct
            %w[campaignId adGroupId campaignBudgetCurrencyCode campaignName adGroupName attributionType purchasedAsin productName productCategory sales14d orders14d unitsSold14d newToBrandSales14d newToBrandPurchases14d newToBrandUnitsSold14d
              newToBrandSalesPercentage14d newToBrandPurchasesPercentage14d newToBrandUnitsSoldPercentage14d]
          end
        end
      end
  end
end
