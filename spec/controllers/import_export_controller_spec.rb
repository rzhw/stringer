require "spec_helper"

app_require "controllers/import_export_controller"

describe "ImportExportController" do
  let(:feeds) { [FeedFactory.build, FeedFactory.build] }

  describe "GET /import/opml" do
    it "displays the import options" do
      get "/import/opml"

      page = last_response.body
      page.should have_tag("input#opml_file")
      page.should have_tag("a#skip")
    end
  end

  describe "POST /import/opml" do
    let(:opml_file) { Rack::Test::UploadedFile.new("spec/sample_data/subscriptions.xml", "application/xml") }

    it "parse OPML and starts fetching" do
      ImportFromOpml.should_receive(:import).once

      post "/import/opml", {"opml_file" => opml_file}

      last_response.status.should be 302
      URI::parse(last_response.location).path.should eq "/setup/tutorial"
    end
  end

  describe "GET /export/opml" do
    let(:some_xml) { "<xml>some dummy opml</xml>"}
    before { Feed.stub(:all) }

    it "returns an OPML file" do
      ExportToOpml.any_instance.should_receive(:to_xml).and_return(some_xml)

      get "/export/opml"

      last_response.body.should eq some_xml
      last_response.header["Content-Type"].should include 'application/octet-stream'
      last_response.header["Content-Disposition"].should == "attachment; filename=\"stringer.xml\""
    end
  end
end
