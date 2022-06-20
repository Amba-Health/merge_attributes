require "active_support"
require "active_support/core_ext/hash/keys"

module MergeAttributes
  DEFAULT_TOKEN_LIST_ATTRIBUTES = [[:class], [:data, :controller], [:data, :action]].freeze
  module Helper
    def merge_attributes(
      attributes, # Ensures we have at least one set of attributes to work with
      *extra_attributes_list, # Collects as many other sets as needed
      token_list_attributes: MergeAttributes::DEFAULT_TOKEN_LIST_ATTRIBUTES,
      **extra_attributes # And keyword params as a final set of attributes
    )
      attributes_to_merge = extra_attributes_list.unshift(attributes)

      # Ruby considers a final hash to be extra options
      # rather than an argument
      unless extra_attributes.blank? # Avoids having an extra hash of attributes in the processing
        attributes_to_merge << extra_attributes
      end

      attributes_to_merge = attributes_to_merge
        .flatten

      if block_given?
        attributes_to_merge = attributes_to_merge.each_with_index.map do |attributes, index|
          yield(attributes, index, attributes_to_merge)
        end
      end # Handle nested arrays that may have been used for collecting series of attributes

      execute_attribute_merge(
        attributes_to_merge.reject { |item| item.blank? }, # No need to process blank values
        token_list_attributes: token_list_attributes
      )
    end

    protected

    def execute_attribute_merge(attributes_list, token_list_attributes: [])
      # Convert all keys to symbol to ensure we
      # don't duplicate keys because one hash provides
      # a String and another a Symbol with the same name
      attributes_list.map(&:deep_symbolize_keys)

      return {} if attributes_list.empty?

      attributes, *attributes_to_merge = attributes_list

      result = attributes

      attributes_to_merge.each do |extra_attributes|
        # deep_merge the attributes so we handle the data Hash properly
        result = result.deep_merge extra_attributes
      end

      token_list_attributes.each do |attribute_path|
        attribute_path = case attribute_path
        when String
          attribute_path.split("-").map(&:to_sym)
        when Array
          attribute_path.map(&:to_sym)
        else
          attribute_path.to_s.split("-").map(&:to_sym)
        end

        value = token_list(attributes.dig(*attribute_path), *attributes_to_merge.map { |attr| attr.dig(*attribute_path) })
        bury(result, *attribute_path, value) unless value.blank?
      end

      result
    end

    # Opposite of `Hash#dig` for deep setting hashes values
    # https://bugs.ruby-lang.org/issues/13179
    def bury(hash, *where, value)
      me = hash
      where[0..-2].each { |key|
        me = me[key] || {} # Create a new hash if the key is not found
      }
      me[where[-1]] = value
    end
  end
end
