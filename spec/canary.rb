# frozen_string_literal: true

class Canary
  attr_reader :called_by
  def initialize
    @callers = []
  end

  def sing(data = nil)
    details = if caller_locations[0] =~ /`block/
                { caller: caller_locations[1], block: true }
              else
                { caller: caller_locations[0], block: false }
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
