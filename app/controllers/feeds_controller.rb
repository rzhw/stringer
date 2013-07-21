require_relative "../repositories/feed_repository"
require_relative "../commands/feeds/add_new_feed"

class Stringer < Sinatra::Base
  get "/feeds" do
    @feeds = FeedRepository.list

    erb :'feeds/index'
  end

  delete "/feeds/:feed_id" do
    FeedRepository.delete(params[:feed_id])

    status 200
  end

  get "/feeds/new" do
    erb :'feeds/add'
  end

  post "/feeds" do
    @feed_url = params[:feed_url]
    feed = AddNewFeed.add(@feed_url)

    if feed and feed.valid?
      FetchFeeds.enqueue([feed])

      flash[:success] = t('feeds.add.flash.added_successfully')
      redirect to("/")
    elsif feed
      flash.now[:error] = t('feeds.add.flash.already_subscribed_error')
      erb :'feeds/add'
    else
      flash.now[:error] = t('feeds.add.flash.feed_not_found_error')
      erb :'feeds/add'
    end
  end
end
