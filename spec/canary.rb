# frozen_string_literal: true

class Canary
  attr_reader :called_by

  def initialize
    @callers = []
  end

  def sing(data = nil)
    details = if /`block/.match?(caller_locations(1..1).first.to_s)
                { caller: caller_locations(2..2).first, block: true }
              else
                { caller: caller_locations(1..1).first, block: false }
              end
    details[:caller] = details[:caller].path.match(%r{[^/]+$})
    @callers << details.merge(data: data)
  end

  def song
    @callers
  end

  def sung?(data)
    @callers.map { |x| x[:data] }.include?(data)
  end
end
