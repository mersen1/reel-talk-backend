# frozen_string_literal: true

module ExternalContent
  class Provider
    %i[home titles search title season person configuration].each do |operation|
      define_method(operation) do |**|
        raise NotImplementedError, "#{self.class} must implement ##{operation}"
      end
    end
  end
end
