module FriendlyId
  module Slugged
    def resolve_friendly_id_conflict(candidates)
      c = candidates.first
      c ||= SecureRandom.uuid[0,16]
      [SecureRandom.uuid[0,6], c[0,48].gsub(/\-$/, '')].compact.join(friendly_id_config.sequence_separator)
    end
  end
end