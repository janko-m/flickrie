require 'spec_helper'

describe Flickrie::Media do
  before(:all) do
    @attributes = {
      :id => PHOTO_ID,
      :secret => '25bb44852b',
      :server => '7049',
      :farm => 8,
      :title => 'IMG_0796',
      :description => 'Test',
      :media_status => 'ready',
      :path_alias => nil,
      :camera => 'Canon PowerShot G12',
      :views_count => 4,
      :comments_count => 1,
      :location => {
        :latitude => 45.807258,
        :longitude => 15.967599,
        :accuracy => '11',
        :context => 0,
        :neighbourhood => nil,
        :locality => {
          :name => 'Zagreb',
          :place_id => '00j4IylZV7scWik',
          :woeid => '851128'
        },
        :county => {
          :name => 'Zagreb',
          :place_id => '306dHrhQV7o6jm.ZUQ',
          :woeid => '15022257'
        },
        :region => {
          :name => 'Grad Zagreb',
          :place_id => 'Js1DU.pTUrpBCIKhVw',
          :woeid => '20070170'
        },
        :country => {
          :name => 'Croatia',
          :place_id => 'FunRCI5TUb6a6soTyw',
          :woeid => '23424843'
        },
        :place_id => '00j4IylZV7scWik',
        :woeid => '851128'
      },
      :geo_permissions => {
        :public? => true,
        :contacts? => false,
        :friends? => false,
        :family? => false
      },
      :tags => {
        :first => {
          :content => 'luka',
          :author => {
            :nsid => USER_NSID
          },
          :raw => 'luka',
          :machine_tag? => false
        }
      },
      :machine_tags => [],
      :license => {:id => '0'},
      :taken_at_granularity => 0,
      :owner => {
        :nsid => USER_NSID,
        :username => USER_USERNAME,
        :real_name => USER_USERNAME,
        :location => "Zagreb, Croatia",
        :icon_server => "5464",
        :icon_farm => 6
      },

      :safety_level => 0,
      :safe? => true,
      :moderate? => false,
      :restricted? => false,

      :visibility => {
        :public? => true,
        :family? => false,
        :friends? => false,
        :contacts? => nil
      },
      :favorite? => false,

      :can_comment? => false,
      :can_add_meta? => false,
      :can_everyone_comment? => true,
      :can_everyone_add_meta? => false,

      :can_download? => true,
      :can_blog? => false,
      :can_print? => false,
      :can_share? => false,

      :has_people? => false,
      :faved? => false,
      :notes => {
        :first => {
          :id => '72157629487842968',
          :author => {
            :nsid => USER_NSID,
            :username => USER_USERNAME
          },
          :coordinates => [316, 0],
          :width => 59,
          :height => 50,
          :content => 'Test'
        }
      }
    }
  end

  context "get info" do
    it "should have all attributes correctly set", :vcr do
      [
        Flickrie.get_media_info(PHOTO_ID),
        Flickrie::Photo.public_new('id' => PHOTO_ID).get_info,
        Flickrie::Video.public_new('id' => PHOTO_ID).get_info
      ].
        each do |media|
          [
            :id, :secret, :server, :farm, :title, :description, :views_count,
            :comments_count, :location, :geo_permissions, :tags,
            :machine_tags, :license, :taken_at_granularity, :owner,
            :safety_level, :safe?, :moderate?, :restricted?, :visibility,
            :favorite?, :can_comment?, :can_add_meta?, :can_everyone_comment?,
            each do |attribute|
              media.send(attribute).should correspond_to(@attributes[attribute])
            end
            :can_everyone_add_meta?, :can_download?, :can_blog?,
            :can_print?, :can_share?, :has_people?, :notes
          ].

          # other
          media.url.empty?.should be_false
          media['id'].should eq(PHOTO_ID)

          # time
          [:posted_at, :uploaded_at, :updated_at, :taken_at].each do |time_attribute|
            media.send(time_attribute).should be_an_instance_of(Time)
          end
        end
    end
  end

  shared_context "common" do
    def test_common_attributes(media)
      [
        :id, :secret, :server, :farm, :title, :media_status, :views_count,
        :geo_permissions, :machine_tags, :license, :taken_at_granularity
      ].
        each do |attribute|
          media.send(attribute).should correspond_to(@attributes[attribute])
        end

      # the incomplete ones

      # other
      media.url.empty?.should be_false
      media.location.should correspond_to(@attributes[:location].except(:locality, :county, :region, :country))
      media.tags.first.should correspond_to(@attributes[:tags][:first].except(:author, :raw, :machine_tag?))
      media.owner.should correspond_to(@attributes[:owner].except(:real_name, :location))

      # time
      [:uploaded_at, :updated_at, :taken_at].each do |time_attribute|
        media.send(time_attribute).should be_an_instance_of(Time)
      end
    end
  end

  context "from set" do
    include_context "common"

    it "should have all attributes correctly set", :vcr do
      media = Flickrie.media_from_set(SET_ID, :extras => EXTRAS).
        find { |media| media.id == PHOTO_ID }
      test_common_attributes(media)
      media.primary?.should be_true
    end
  end

  context "from user" do
    include_context "common"

    it "should have all attributes correctly set", :vcr do
      media = Flickrie.media_from_user(USER_NSID, :extras => EXTRAS).
        find { |media| media.id == PHOTO_ID }
      test_common_attributes(media)
      media.visibility.should correspond_to(@attributes[:visibility])
    end
  end

  context "public from user" do
    include_context "common"

    it "should have all attributes correctly set", :vcr do
      media = Flickrie.public_media_from_user(USER_NSID, :extras => EXTRAS).
        find { |media| media.id == PHOTO_ID }
      test_common_attributes(media)
      media.visibility.should correspond_to(@attributes[:visibility])
    end
  end

  context "search" do
    include_context "common"

    it "should have all attributes correctly set", :vcr do
      media = Flickrie.search_media(:user_id => USER_NSID, :extras => EXTRAS).
        find { |media| media.id == PHOTO_ID }
      test_common_attributes(media)
      media.visibility.should correspond_to(@attributes[:visibility])
    end
  end

  context "from contacts" do
    it "should have all attributes correctly set", :vcr do
      params = {:include_self => 1, :single_photo => 1}
      [
        Flickrie.media_from_contacts(params).first,
        Flickrie.public_media_from_user_contacts(USER_NSID, params).first
      ].
        each do |media|
          media.id.should eq('7093101501')
          media.secret.should eq('9337f28800')
          media.server.should eq('7090')
          media.farm.should eq(8)
          media.owner.nsid.should eq(USER_NSID)
          media.owner.username.should eq(USER_USERNAME)
          media.title.should eq('IMG_0917')
          test_recursively(media, :visibility)
          media.media_status.should eq('ready')
        end
    end
  end

  context "get context" do
    it "should have all attributes correctly set", :vcr do
      context = Flickrie.get_media_context(PHOTO_ID)
      context.count.should eq(98)
      context.previous.title.should eq('IMG_0795')
      context.previous.url.should_not be_empty
      context.previous.faved?.should be_false
    end
  end

  context "blank media" do
    it "should have all attributes equal to nil" do
      attributes = Flickrie::Media.instance_methods -
        Object.instance_methods -
        [:[], :get_info, :get_exif, :get_favorites]

      media = Flickrie::Photo.public_new
      attributes.each do |attribute|
        media.send(attribute).should be_nil
      end
    end
  end

  context "get exif" do
    it "should get exif correctly", :vcr do
      [
        Flickrie.get_photo_exif(PHOTO_ID),
        Flickrie::Photo.public_new('id' => PHOTO_ID).get_exif
      ].
        each do |photo|
          photo.camera.should eq('Canon PowerShot G12')
          photo.exif.get('X-Resolution').should eq('180 dpi')
          photo.exif.get('X-Resolution', :data => 'clean').should eq('180 dpi')
          photo.exif.get('X-Resolution', :data => 'raw').should eq('180')
        end
    end
  end
end
