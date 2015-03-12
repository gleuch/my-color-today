module FriendlyId
  module Slugged
    def resolve_friendly_id_conflict(candidates)
      SecureRandom.uuid[0,6] + friendly_id_config.sequence_separator + candidates.first[0,48].gsub(/\-$/, '')
    end
  end
end