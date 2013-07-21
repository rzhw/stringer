require_relative "../repositories/feed_repository"
require_relative "../repositories/user_repository"
require_relative "../commands/import_export/import_from_opml"
require_relative "../commands/import_export/import_from_starredjson"
require_relative "../commands/import_export/export_to_opml"

class Stringer < Sinatra::Base
  namespace "/import" do
    get "/opml" do
      erb :'import/opml'
    end

    post "/opml" do
      ImportFromOpml.import(params["opml_file"][:tempfile].read)

      redirect to("/setup/tutorial")
    end

    get "/starredjson" do
      erb :'import/starredjson'
    end

    post "/starredjson" do
      ImportFromStarredJson.import(params["starred_file"][:tempfile].read)

      redirect to("/starred")
    end
  end

  namespace "/export" do
    get "/opml" do
      content_type 'application/octet-stream'
      attachment 'stringer.xml'

      ExportToOpml.new(Feed.all).to_xml
    end
  end
end
