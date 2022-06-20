require "merge_attributes/helper"

RSpec.describe MergeAttributes::Helper, type: :helper do
  it "deep merges attributes that are not marked as token list" do
    expect(helper.merge_attributes([
      {
        id: "an-id",
        data: {
          url: "http://example.com"
        }
      }, {
        rel: "noopener",
        data: {
          remote: true
        }
      }
    ])).to eq({
      id: "an-id",
      rel: "noopener",
      data: {
        remote: true,
        url: "http://example.com"
      }
    })
  end

  describe "arguments" do
    it "ignores nil values" do
      expect(helper.merge_attributes([
        nil,
        {
          id: "an-id",
          data: {
            url: "http://example.com"
          }
        },
        nil,
        {
          rel: "noopener",
          data: {
            remote: true
          }
        },
        nil
      ])).to eq({
        id: "an-id",
        rel: "noopener",
        data: {
          remote: true,
          url: "http://example.com"
        }
      })
    end

    it "accepts hashes as arguments" do
      expect(helper.merge_attributes(
        {
          id: "an-id",
          data: {
            url: "http://example.com"
          }
        }, {
          rel: "noopener",
          data: {
            remote: true
          }
        }
      )).to eq({
        id: "an-id",
        rel: "noopener",
        data: {
          remote: true,
          url: "http://example.com"
        }
      })
    end

    it "flattens any arrays passed" do
      expect(helper.merge_attributes(
        [
          [{
            id: "an-id"
          }],
          {
            data: {
              url: "http://example.com"
            }
          }
        ],
        [
          {
            rel: "noopener"
          },
          [{
            data: {
              remote: true
            }
          }]
        ]
      )).to eq({
        id: "an-id",
        rel: "noopener",
        data: {
          remote: true,
          url: "http://example.com"
        }
      })
    end

    it "executes token_list when single item is passed" do
      expect(helper.merge_attributes({
        class: [{here: true, not_here: false}, "there", ["or", "somewhere"]]
      })).to eq({
        class: "here there or somewhere"
      })
    end
  end

  describe "token_list_attributes option" do
    it "merges listed attribute as a token list" do
      expect(helper.merge_attributes([{
        class: "class-1"
      }, {
        class: ["class-2 class-3"]
      }, {
        class: {
          "class-4": true
        }
      }], token_list_attributes: [:class])).to eq({
        class: "class-1 class-2 class-3 class-4"
      })
    end

    it "support deep keys" do
      expect(helper.merge_attributes([{
        data: {
          controller: "controller-1"
        }
      }, {
        data: {
          controller: ["controller-2 controller-3"]
        }
      }, {
        data: {
          controller: {
            "controller-4": true
          }
        }
      }], token_list_attributes: [[:data, :controller]])).to eq({
        data: {
          controller: "controller-1 controller-2 controller-3 controller-4"
        }
      })
    end

    it "support string lists" do
      expect(helper.merge_attributes([{
        data: {
          controller: "controller-1"
        }
      }, {
        data: {
          controller: ["controller-2 controller-3"]
        }
      }, {
        data: {
          controller: {
            "controller-4": true
          }
        }
      }], token_list_attributes: [["data", "controller"]])).to eq({
        data: {
          controller: "controller-1 controller-2 controller-3 controller-4"
        }
      })
    end

    it "supports dash separated strings" do
      expect(helper.merge_attributes([{
        data: {
          controller: "controller-1"
        }
      }, {
        data: {
          controller: ["controller-2 controller-3"]
        }
      }, {
        data: {
          controller: {
            "controller-4": true
          }
        }
      }], token_list_attributes: ["data-controller"])).to eq({
        data: {
          controller: "controller-1 controller-2 controller-3 controller-4"
        }
      })
    end
  end

  describe "block" do
    it "allows pre-processing of attributes" do
      result = helper.merge_attributes([{
        id: "number-1"
      }, {
        class: "boom"
      }, {
        "aria-label": "Hello"
      }]) do |attributes, index|
        {
          **attributes,
          "data-value-#{index}": index
        }
      end

      expect(result).to eq({
        id: "number-1",
        class: "boom",
        "aria-label": "Hello",
        "data-value-0": 0,
        "data-value-1": 1,
        "data-value-2": 2
      })
    end

    it "provides the flattened list of attributes" do
      helper.merge_attributes(
        {id: "number-1"},
        [[{class: "boom"}]],
        "aria-label": "Hello"
      ) do |attributes, index, attributes_list|
        expect(attributes_list).to eq([
          {id: "number-1"},
          {class: "boom"},
          {"aria-label": "Hello"}
        ])

        attributes
      end
    end
  end
end
