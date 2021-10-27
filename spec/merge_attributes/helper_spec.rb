require "merge_attributes/helper"

RSpec.describe MergeAttributes::Helper, type: :helper do

  it 'deep merges attributes that are not marked as token list' do
    expect(helper.merge_attributes([
      {
        id: "an-id", 
        data: {
          url: 'http://example.com'
        }
      }, {
        rel: 'noopener',
        data: {
          remote: true
        }
      }
    ])).to eq({
        id: "an-id",
        rel: 'noopener',
        data: {
          remote: true,
          url: 'http://example.com'
        }
      })
  end
end
