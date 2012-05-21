require 'spec_helper'

describe Flickrie::Instance do
  context "client is already initialized" do
    it "should be able to call API methods", :vcr do
      # this is to see if the client and upload_client were reset
      Flickrie.get_photo_info(PHOTO_ID)
      id = Flickrie.upload(PHOTO_PATH)
      Flickrie.delete_photo(id)
      Flickrie.access_token = Flickrie.access_secret = nil

      instance = Flickrie::Instance.new(ENV['FLICKR_ACCESS_TOKEN'], ENV['FLICKR_ACCESS_SECRET'])
      user = instance.test_login
      user.username.should eq(USER_USERNAME)
    end
  end
end
