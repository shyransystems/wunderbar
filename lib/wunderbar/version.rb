module Wunderbar
  module VERSION #:nodoc:
    MAJOR = 1
    MINOR = 0
    TINY  = 18

    STRING = [MAJOR, MINOR, TINY].join('.')
  end
end unless defined?(Wunderbar::VERSION)
