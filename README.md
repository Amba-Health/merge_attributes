# MergeAttributes

Merge hashes of HTML attributes, properly aggregating `class` and other [DOMTokenList]-like fields like Stimulus' `data-controller` or `data-action` (or also ARIA's `aria-labelledby` or `aria-describedby` if you so chose).

The resulting `Hash` can then be provided to the `tag.<tag name>` helper to generate an HTML tag with the corresponding attributes (or to `content_tag`, or as [HAML attributes] with a [double splat], or whatever needs a hash of attributes)

[HAML attributes]: https://haml.info/tutorial.html#adding_attributes
[double splat]: https://michaeljherold.com/articles/using-double-splat-operator-ruby/
[DOMTokenList]: https://developer.mozilla.org/en-US/docs/Web/API/DOMTokenList

This allows finer control of the provenance on the attributes assigned to a given elements, like splitting its "own" attributes vs. those coming from the parent it's rendered in:

```rb
merge_attributes(
  # Styles responsible for the component's look itself
  {class: 'my-component'}, 
  {
    # Styles responsible for adjusting the component 
    # because it's rendered inside `parent-component`
    class: 'parent-component__child', 
    # Extra action that the element would not usually have
    data: {action: 'stimulus-controller#action'}
  }
)
# Creates: {class: 'my-component parent_component__child',data: {action: 'stimulus-controller#action'}}
```

This also opens the door to abstracting specific sets of components in their own helpers to provide specific vocabulary, say for configuring specific Stimulus controllers

```rb
merge_attributes(
  {class: 'my-component'},
  # Returns the right Stimulus controller/actions/values
  # to properly wire the element to open the given dialog
  dialog_trigger(dialog_id: 'my-dialog') 
)
```

## Installation

### Requirements

The helper delegate some of its behaviour to [Rails 6.1 `token_list` helper][token-list-helper].

If you're running on an older version of Rails, your could alias [Primer ViewComponent's `class_names` helper][primer-class-names-helper], which replicates the same feature.

[token-list-helper]: https://api.rubyonrails.org/classes/ActionView/Helpers/TagHelper.html#method-i-token_list
[primer-class-names-helper]: https://github.com/primer/view_components/blob/60fc38f08915ce42f8965f2cc8f3474ab317438c/app/lib/primer/class_name_helper.rb

### Installing the Gem

```ruby
# Ideally replace the `branch: "main"` with a commit reference (`ref: COMMIT_HASH`)
# https://bundler.io/guides/git.html
gem "merge_attributes", github: "Amba-Health/merge_attributes", branch: "main"
```

<details>
<summary>Coming soon!</summary>

Add this line to your application's Gemfile:

```ruby
gem 'merge_attributes'
```

And then execute:

    bundle

Or install it yourself as:

    gem install merge_attributes

</details>

## Usage

###  Providing the attributes

The method is flexible in the attributes it accepts and can be provided. All the examples bellow will generate the same final Hash of attributes:

```rb
{
    id: 'the-id',
    class: 'a-class',
    data:{ 
        dialog_id: 'confirm'
    }
}
```

The method supports:

- `Hash`es

    ```rb
    merge_attributes({
        id: 'the-id'
    }, {
        class: 'a-class'
    },{
        data: {
            dialog_id: 'confirm'
        }
    })
    ```

- an `Array` or `Array`s of `Hash`es

    Nested arrays will be flattened, allowing you to directly pass a list of attributes you'd collected in another part of your app.

    ```rb
    merge_attributes([{
        id: 'the-id'
    }, [{
        class: 'a-class'
    }]],[{
        data: {
            dialog_id: 'confirm'
        }
    }])
    ```

- Keyword arguments

    Any keyword argument (aside from [`token_list_attributes`, see below](#token-list-attributes)) is treated as a final `Hash` of attributes

    ```rb
    merge_attributes({
        id: 'the-id',
        class: 'a-class'
    }, 
        data: {
            dialog_id: 'confirm'
        }
    )
    ```

- Mix'n'match

    You can mix the different kind of attributes
    in a single call

    ```rb
    merge_attributes({
        id: 'the-id'
    }, [[{
        class: 'a-class'
    }]],
        data: {
            dialog_id: 'confirm'
        }
    )
    ```

Any `.blank?` value (after [pre-processing, see below](#pre-processing)) will be ignored.

### Token list attributes

Attributes will generally be `deep_merged`, the value of the latest one in the list replacing any existing ones.

This model doesn't really work for the `class` attribute, where it's preferable that the values get concatenated with a space. Same goes for other attributes, like `data-action` or `data-controller` from Stimulus.

Out of the box, `merge_attributes` will concatenate the values of these attributes rather than replace them:

```rb
merge_attributes({
    class: 'my-component'
}, {
    class: 'parent-component__child'
})
```

generates

```rb
{
    class: 'my-component parent-component__child'
}
```

### Attributes format

The concatenation is done using [Rails's `token_list` helper][token-list-helper]. This means it accepts not only `Strings`, but `Array`s of `Strings` or `Hash`es with `true` or `false` values:

```rb
merge_attributes({
    class: 'my-component'
}, {
    class: ['parent-component__child','my-component--variation']
}, {
    class: {
        active: true
    }
})
```

###  Adding other attributes

You may want to treat other attributes that way. ARIA's `aria-labelledby` and `aria-describedby` would be great candidates for it for example.

The method accepts the `token_list_attributes` keyword argument for providing a list of attributes to concatenate:

```rb
merge_attributes({
    'aria-labelledby': 'delete_action'
}, {
    'aria-labelledby': 'user_1'
},
    token_list_attributes: [
        *MergeAttributes::DEFAULT_TOKEN_LIST_ATTRIBUTES,
        'aria-labelledby'
    ]
)
```

As illustrated in the example, the `MergeAttributes::DEFAULT_TOKEN_LIST_ATTRIBUTES` will help you add to the default list.

###  Pre-processing

The method accepts a block that'll let you process the attributes prior to their merging (but after the different arguments have been collected and flattened into a single `Array`).

This is the perfect time to call `to_h` if some of the attributes are not hashes already. Or resolve any conflicts between attributes in the `data` hash and as `data-...` keys.

The block will be provided:

- the current `Hash` being pre-processed
- its index in the whole attribute list
- the attribute list itself

It is expected to return the transformed list of attributes (or a `.blank?` value if you want to filter it out)

```rb
merge_attributes({
    class: 'my-component'
}, class: {
    class: 'parent-component__child'
}) do |attributes, index, attributes_list|
    attributes.merge({
        # Dummy example
        "data-item-#{index}": index
    })
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/Amba-Health/merge_attributes>. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the MergeAttributes project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/Amba-Health/merge_attributes/blob/master/CODE_OF_CONDUCT.md).
