RSpec.describe MergeAttributes do
  it "has a version number" do
    expect(MergeAttributes.gem_version).to be_a Gem::Version
  end
end
