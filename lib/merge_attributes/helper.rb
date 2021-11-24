require "active_support"
require "active_support/core_ext/hash/keys"

module MergeAttributes

  DEFAULT_TOKEN_LIST_ATTRIBUTES = [[:class], [:data, :controller], [:data,:action]].freeze
  module Helper

    def merge_attributes(
      attributes, 
      *extra_attributes_list, 
      token_list_attributes: MergeAttributes::DEFAULT_TOKEN_LIST_ATTRIBUTES,
      **extra_attributes
    )
      attributes_to_merge = extra_attributes_list.unshift(attributes)

      # Ruby considers a final hash to be extra options
      # rather than an argument
      attributes_to_merge << extra_attributes
    
      attributes_to_merge = attributes_to_merge
        .flatten # Handle nested arrays that may have been used for collecting series of attributes
        .reject{|item| item.blank?} # No need to process blank values
      
      execute_attribute_merge(attributes_to_merge, token_list_attributes: token_list_attributes)
    end

    private

    def execute_attribute_merge(attributes_list, token_list_attributes: [])
      # Convert all keys to symbol to ensure we
      # don't duplicate keys because one hash provides
      # a String and another a Symbol with the same name
      attributes_list.map(&:deep_symbolize_keys)

      return {} if attributes_list.empty?

      attributes, *attributes_to_merge = attributes_list

      return attributes if attributes_list.size == 1

      result = attributes

      attributes_to_merge.each do |extra_attributes|
        # deep_merge the attributes so we handle the data Hash properly
        result = result.deep_merge extra_attributes
      end 

      token_list_attributes.each do |attribute_path|
        value = token_list(attributes.dig(*attribute_path), *attributes_to_merge.map{|attr| attr.dig(*attribute_path)})
        bury(result, *attribute_path, value) unless value.blank?
      end

      result
    end

    # Opposite of `Hash#dig` for deep setting hashes values
    # https://bugs.ruby-lang.org/issues/13179
    def bury(hash, *where, value)
        me=hash
        where[0..-2].each{|key|
          me=me[key] || {} # Create a new hash if the key is not found
        }
        me[where[-1]]=value
    end
  end
end
