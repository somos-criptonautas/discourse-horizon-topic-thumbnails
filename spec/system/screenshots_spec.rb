# frozen_string_literal: true

# README screenshots. Run by the "Screenshots" workflow, which commits the PNGs
# to docs/screenshots/. Skipped in regular CI.
RSpec.describe "Screenshots" do
  before { skip "set SCREENSHOTS=1 to take screenshots" unless ENV["SCREENSHOTS"] }

  fab!(:author) { Fabricate(:user, username: "satoshi") }
  fab!(:category) { Fabricate(:category, name: "Bitcoin") }

  let!(:horizon) do
    SystemThemesManager.sync_theme!("horizon")
    theme = Theme.horizon_theme
    theme.update!(enabled: true, user_selectable: true)
    SiteSetting.default_theme_id = theme.id
    theme
  end
  let!(:component) { upload_theme_component(parent_theme_id: horizon.id) }

  def cover(name)
    file = File.open(File.expand_path("../fixtures/#{name}.jpg", __dir__))
    UploadCreator.new(file, "#{name}.jpg").create_for(author.id)
  end

  def save(name)
    path = Rails.root.join("tmp/capybara/screenshots/#{name}.png")
    FileUtils.mkdir_p(path.dirname)
    page.save_screenshot(path.to_s)
  end

  before do
    [
      ["Running your own Bitcoin node", "cover-a"],
      ["Lightning channels, explained without jargon", "cover-b"],
      ["What changed in the last soft fork", nil],
      ["Self-custody checklist for new members", "cover-c"],
    ].each do |title, image|
      topic = Fabricate(:topic_with_op, title: title, category: category, user: author)
      topic.update!(image_upload_id: cover(image).id) if image
    end
  end

  it "shows thumbnails on desktop" do
    resize_window(width: 1280, height: 900) do
      visit "/c/#{category.slug}/#{category.id}"
      expect(page).to have_css(".htt-thumbnail-cell img", count: 3)
      save("thumbnails-desktop")
    end
  end

  it "shows thumbnails as banners on mobile" do
    resize_window(width: 390, height: 844) do
      visit "/c/#{category.slug}/#{category.id}"
      expect(page).to have_css(".htt-thumbnail-cell img", minimum: 1)
      save("thumbnails-mobile")
    end
  end
end
