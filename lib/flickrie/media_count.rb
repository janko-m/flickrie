require 'date'

module Flickrie
  class MediaCount
    # @!parse attr_reader \
    #   :value, :date_range, :from, :to, :hash

    def value() Integer(@info['count']) rescue nil end

    # @return [Range]
    def date_range
      dates =
        case @dates_kind
        when "mysql timestamp"
          [DateTime.parse(@info['fromdate']).to_time,
           DateTime.parse(@info['todate']).to_time]
        when "unix timestamp"
          [Time.at(Integer(@info['fromdate'])),
           Time.at(Integer(@info['todate']))]
        end

      dates.first..dates.last
    end
    alias time_interval date_range

    # @return [Time]
    def from() date_range.begin end
    # @return [Time]
    def to()   date_range.end   end

    def [](key) @info[key] end
    # Returns the raw hash from the response. Useful if something isn't available by methods.
    #
    # @return [Hash]
    def hash() @info end

    private

    def initialize(info, params)
      @info = info
      @dates_kind = (params[:dates].nil? ? "mysql timestamp" : "unix timestamp")
    end

    def self.ensure_utc(params)
      params.dup.tap do |hash|
        if hash[:taken_dates].is_a?(String)
          hash[:taken_dates] = hash[:taken_dates].split(',').
            map { |date| DateTime.parse(date) }.
            map(&:to_time).map(&:getutc).join(',')
        end
      end
    end
  end
end
