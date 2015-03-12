class Hash

  def in_groups_of(*args)
    to_a.in_groups_of(*args).inject([]) do |accum, group|
      accum << group.inject({}) {|acc, pair| pair.nil? ? acc : acc.merge(pair.first => pair.last)}
    end
  end

end
