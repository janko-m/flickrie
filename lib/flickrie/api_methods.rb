module Flickrie
  module ApiMethods

    include Callable
    extend Deprecatable

    # For uploading photos and videos to Flickr. Example:
    #
    #     path = File.expand_path("photo.jpg")
    #     photo_id = Flickrie.upload(path, title: "Me and Jessica", description: "...")
    #     photo = Flickrie.get_photo_info(photo_id)
    #     photo.title # => "Me and Jessica"
    #
    # If the `async: 1` option is passed, returns the ticket ID (see {#check\_upload\_tickets}).
    #
    # @param media [File, String] A file or a path to the file you want to upload
    # @param params [Hash] Options for uploading (see [this page](http://www.flickr.com/services/api/upload.api.html))
    # @return [String] New photo's ID, or ticket's ID, if `async: 1` is passed
    #
    # @note This method requires authentication with "write" permissions.
    def upload(media, params = {})
      response = make_request(media, params)
      if params[:async] == 1
        response.body['rsp']['ticketid']
      else
        response.body['rsp']['photoid']
      end
    end

    # For replacing photos and videos on Flickr. Example:
    #
    #     path = File.expand_path("photo.jpg")
    #     photo_id = 42374 # ID of the photo to be replaced
    #     id = Flickrie.replace(path, photo_id)
    #
    # If the `async: 1` option is passed, returns the ticket ID (see {#check\_upload\_tickets}).
    #
    # @param media [File, String] A file or a path to the file you want to upload
    # @param media_id [String, Fixnum] The ID of the photo/video to be replaced
    # @param params [Hash] Options for replacing (see [this page](http://www.flickr.com/services/api/replace.api.html))
    # @return [String] New photo's ID, or ticket's ID, if `async: 1` is passed
    #
    # @note This method requires authentication with "write" permissions.
    def replace(media, media_id, params = {})
      response = make_request(media, media_id, params)
      if params[:async] == 1
        response.body['rsp']['ticketid']
      else
        response.body['rsp']['photoid']
      end
    end

    # Fetches the Flickr user with the given email.
    #
    # @return [Flickrie::User]
    # @api_method [flickr.people.findByEmail](http://www.flickr.com/services/api/flickr.people.findByEmail.html)
    def find_user_by_email(email, params = {})
      response = make_request(email, params)
      User.new(response.body['user'], self)
    end

    # Fetches the Flickr user with the given username.
    #
    # @return [Flickrie::User]
    # @api_method [flickr.people.findByUsername](http://www.flickr.com/services/api/flickr.people.findByUsername.html)
    def find_user_by_username(username, params = {})
      response = make_request(username, params)
      User.new(response.body['user'], self)
    end

    # Fetches photos and videos from the Flickr user with the given NSID.
    #
    # @return [Flickrie::Collection<Flickrie::Photo, Flickrie::Video>]
    # @api_method [flickr.people.getPhotos](http://www.flickr.com/services/api/flickr.people.getPhotos.html)
    #
    # @note This method requires authentication with "read" permissions.
    def get_media_from_user(nsid, params = {})
      response = make_request(nsid, params)
      Media.new_collection(response.body['photos'], self)
    end
    deprecated_alias :media_from_user, :get_media_from_user
    # Fetches photos from the Flickr user with the given NSID.
    #
    # @return [Flickrie::Collection<Flickrie::Photo>]
    # @api_method [flickr.people.getPhotos](http://www.flickr.com/services/api/flickr.people.getPhotos.html)
    #
    # @note This method requires authentication with "read" permissions.
    def get_photos_from_user(nsid, params = {})
      get_media_from_user(nsid, params).select { |media| media.is_a?(Photo) }
    end
    deprecated_alias :photos_from_user, :get_photos_from_user
    # Fetches videos from the Flickr user with the given NSID.
    #
    # @return [Flickrie::Collection<Flickrie::Video>]
    # @api_method [flickr.people.getPhotos](http://www.flickr.com/services/api/flickr.people.getPhotos.html)
    #
    # @note This method requires authentication with "read" permissions.
    def get_videos_from_user(nsid, params = {})
      get_media_from_user(nsid, params).select { |media| media.is_a?(Video) }
    end
    deprecated_alias :videos_from_user, :get_videos_from_user

    # Fetches photos and videos containing a Flickr user with the given NSID.
    #
    # @return [Flickrie::Collection<Flickrie::Photo, Flickrie::Video>]
    # @api_method [flickr.people.getPhotosOf](http://www.flickr.com/services/api/flickr.people.getPhotosOf.html)
    def get_media_of_user(nsid, params = {})
      response = make_request(nsid, params)
      Media.new_collection(response.body['photos'], self)
    end
    deprecated_alias :media_of_user, :get_media_of_user
    # Fetches photos containing a Flickr user with the given NSID.
    #
    # @return [Flickrie::Collection<Flickrie::Photo>]
    # @api_method [flickr.people.getPhotosOf](http://www.flickr.com/services/api/flickr.people.getPhotosOf.html)
    def get_photos_of_user(nsid, params = {})
      get_media_of_user(nsid, params).select { |media| media.is_a?(Photo) }
    end
    deprecated_alias :photos_of_user, :get_photos_of_user
    # Fetches videos containing a Flickr user with the given NSID.
    #
    # @return [Flickrie::Collection<Flickrie::Video>]
    # @api_method [flickr.people.getPhotosOf](http://www.flickr.com/services/api/flickr.people.getPhotosOf.html)
    def get_videos_of_user(nsid, params = {})
      get_media_of_user(nsid, params).select { |media| media.is_a?(Video) }
    end
    deprecated_alias :videos_of_user, :get_videos_of_user

    # Fetches public photos and videos from the Flickr user with the given
    # NSID.
    #
    # @return [Flickrie::Collection<Flickrie::Photo, Flickrie::Video>]
    # @api_method [flickr.people.getPublicPhotos](http://www.flickr.com/services/api/flickr.people.getPublicPhotos.html)
    def get_public_media_from_user(nsid, params = {})
      response = make_request(nsid, params)
      Media.new_collection(response.body['photos'], self)
    end
    deprecated_alias :public_media_from_user, :get_public_media_from_user
    # Fetches public photos from the Flickr user with the given NSID.
    #
    # @return [Flickrie::Collection<Flickrie::Photo>]
    # @api_method [flickr.people.getPublicPhotos](http://www.flickr.com/services/api/flickr.people.getPublicPhotos.html)
    def get_public_photos_from_user(nsid, params = {})
      get_public_media_from_user(nsid, params).select { |media| media.is_a?(Photo) }
    end
    deprecated_alias :public_photos_from_user, :get_public_photos_from_user
    # Fetches public videos from the Flickr user with the given NSID.
    #
    # @return [Flickrie::Collection<Flickrie::Video>]
    # @api_method [flickr.people.getPublicPhotos](http://www.flickr.com/services/api/flickr.people.getPublicPhotos.html)
    def get_public_videos_from_user(nsid, params = {})
      get_public_media_from_user(nsid, params).select { |media| media.is_a?(Video) }
    end
    deprecated_alias :public_videos_from_user, :get_public_videos_from_user

    # Fetches the Flickr user with the given NSID.
    #
    # @return [Flickrie::User]
    # @api_method [flickr.people.getInfo](http://www.flickr.com/services/api/flickr.people.getInfo.html)
    def get_user_info(nsid, params = {})
      response = make_request(nsid, params)
      User.new(response.body['person'], self)
    end

    # Returns the upload status of the user who is currently authenticated.
    #
    # @return [Flickrie::User]
    # @api_method [flickr.people.getUploadStatus](http://www.flickr.com/services/api/flickr.people.getUploadStatus.html)
    # @see Flickrie::User#upload_status
    #
    # @note This method requires authentication with "read" permissions.
    def get_upload_status(params = {})
      response = make_request(params)
      User.new(response.body['user'], self)
    end

    # Add tags to the photo/video with the given ID.
    #
    # @param tags [String] A space delimited string with tags
    # @return [nil]
    # @api_method [flickr.photos.addTags](http://www.flickr.com/services/api/flickr.photos.addTags.html)
    #
    # @note This method requires authentication with "write" permissions.
    def tag_media(media_id, tags, params = {})
      make_request(media_id, tags, params)
      nil
    end
    deprecated_alias :add_media_tags, :tag_media
    alias tag_photo tag_media
    deprecated_alias :add_photo_tags, :tag_photo
    alias tag_video tag_media
    deprecated_alias :add_video_tags, :tag_video

    # Deletes the photo/video with the given ID.
    #
    # @return [nil]
    # @api_method [flickr.photos.delete](http://www.flickr.com/services/api/flickr.photos.delete.html)
    #
    # @note This method requires authentication with "delete" permissions.
    def delete_media(media_id, params = {})
      make_request(media_id, params)
      nil
    end
    alias delete_photo delete_media
    alias delete_video delete_media

    # Fetches photos and videos from contacts of the user who authenticated.
    #
    # @return [Flickrie::Collection<Flickrie::Photo, Flickrie::Video>]
    # @api_method [flickr.photos.getContactsPhotos](http://www.flickr.com/services/api/flickr.photos.getContactsPhotos.html)
    #
    # @note This method requires authentication with "read" permissions.
    def get_media_from_contacts(params = {})
      response = make_request(params)
      Media.new_collection(response.body['photos'], self)
    end
    deprecated_alias :media_from_contacts, :get_media_from_contacts
    # Fetches photos from contacts of the user who authenticated.
    #
    # @return [Flickrie::Collection<Flickrie::Photo>]
    # @api_method [flickr.photos.getContactsPhotos](http://www.flickr.com/services/api/flickr.photos.getContactsPhotos.html)
    #
    # @note This method requires authentication with "read" permissions.
    def get_photos_from_contacts(params = {})
      get_media_from_contacts(params).select { |media| media.is_a?(Photo) }
    end
    deprecated_alias :photos_from_contacts, :get_photos_from_contacts
    # Fetches videos from contacts of the user who authenticated.
    #
    # @return [Flickrie::Collection<Flickrie::Video>]
    # @api_method [flickr.photos.getContactsPhotos](http://www.flickr.com/services/api/flickr.photos.getContactsPhotos.html)
    #
    # @note This method requires authentication with "read" permissions.
    def get_videos_from_contacts(params = {})
      get_media_from_contacts(params).select { |media| media.is_a?(Video) }
    end
    deprecated_alias :videos_from_contacts, :get_videos_from_contacts

    # Fetches public photos and videos from contacts of the user with the
    # given NSID.
    #
    # @return [Flickrie::Collection<Flickrie::Photo, Flickrie::Video>]
    # @api_method [flickr.photos.getContactsPublicPhotos](http://www.flickr.com/services/api/flickr.photos.getContactsPublicPhotos.html)
    def get_public_media_from_contacts(nsid, params = {})
      response = make_request(nsid, params)
      Media.new_collection(response.body['photos'], self)
    end
    deprecated_alias :public_media_from_user_contacts, :get_public_media_from_contacts
    # Fetches public photos from contacts of the user with the
    # given NSID.
    #
    # @return [Flickrie::Collection<Flickrie::Photo>]
    # @api_method [flickr.photos.getContactsPublicPhotos](http://www.flickr.com/services/api/flickr.photos.getContactsPublicPhotos.html)
    def get_public_photos_from_contacts(nsid, params = {})
      get_public_media_from_contacts(nsid, params).select { |media| media.is_a?(Photo) }
    end
    deprecated_alias :public_photos_from_user_contacts, :get_public_photos_from_contacts
    # Fetches public videos from contacts of the user with the
    # given NSID.
    #
    # @return [Flickrie::Collection<Flickrie::Video>]
    # @api_method [flickr.photos.getContactsPublicPhotos](http://www.flickr.com/services/api/flickr.photos.getContactsPublicPhotos.html)
    def get_public_videos_from_contacts(nsid, params = {})
      get_public_media_from_contacts(nsid, params).select { |media| media.is_a?(Video) }
    end
    deprecated_alias :public_videos_from_user_contacts, :get_public_videos_from_contacts

    # Fetches context of the photo/video with the given ID. Example:
    #
    #     context = Flickrie.get_photo_context(37124234)
    #     context.count    # => 23
    #     context.previous # => #<Photo: id=2433240, ...>
    #     context.next     # => #<Video: id=1282404, ...>
    #
    # @return [Flickrie::MediaContext]
    # @api_method [flickr.photos.getContext](http://www.flickr.com/services/api/flickr.photos.getContext.html)
    def get_media_context(media_id, params = {})
      response = make_request(media_id, params)
      MediaContext.new(response.body, self)
    end
    alias get_photo_context get_media_context
    alias get_video_context get_media_context

    # Fetches numbers of photos and videos for given date ranges. Example:
    #
    #     require 'date'
    #     dates = [DateTime.parse("3rd Jan 2011").to_time, DateTime.parse("11th Aug 2011").to_time]
    #     counts = Flickrie.get_media_counts(taken_dates: dates.map(&:to_i).join(','))
    #
    #     count = counts.first
    #     count.value            # => 24
    #     count.date_range       # => 2011-01-03 01:00:00 +0100..2011-08-11 02:00:00 +0200
    #     count.date_range.begin # => 2011-01-03 01:00:00 +0100
    #     count.from             # => 2011-01-03 01:00:00 +0100
    #
    # @return [Flickrie::MediaCount]
    # @api_method [flickr.photos.getCounts](http://www.flickr.com/services/api/flickr.photos.getCounts.html)
    def get_media_counts(params = {})
      response = make_request(params)
      MediaCount.new_collection(response.body['photocounts'])
    end
    alias get_photos_counts get_media_counts
    alias get_videos_counts get_media_counts

    # Fetches the exif for the photo with the given ID. Example:
    #
    #     photo = Flickrie.get_photo_exif(27234987)
    #     photo.exif.get('Model') # => 'Canon PowerShot G12'
    #
    #     photo.exif.get('X-Resolution', data: 'raw')   # => '180'
    #     photo.exif.get('X-Resolution', data: 'clean') # => '180 dpi'
    #     photo.exif.get('X-Resolution')                   # => '180 dpi'
    #
    # @param photo_id [String, Fixnum]
    # @return [Flickrie::Photo]
    # @api_method [flickr.photos.getExif](http://www.flickr.com/services/api/flickr.photos.getExif.html)
    def get_photo_exif(photo_id, params = {})
      response = make_request(photo_id, params)
      Photo.new(response.body['photo'], self)
    end
    # Fetches the exif for the video with the given ID. Example:
    #
    #     video = Flickrie.get_video_exif(27234987)
    #     video.exif.get('Model') # => 'Canon PowerShot G12'
    #
    #     video.exif.get('X-Resolution', data: 'raw')   # => '180'
    #     video.exif.get('X-Resolution', data: 'clean') # => '180 dpi'
    #     video.exif.get('X-Resolution')                   # => '180 dpi'
    #
    # @param video_id [String, Fixnum]
    # @return [Flickrie::Video]
    # @api_method [flickr.photos.getExif](http://www.flickr.com/services/api/flickr.photos.getExif.html)
    def get_video_exif(video_id, params = {})
      response = make_request(video_id, params)
      Video.new(response.body['photo'], self)
    end

    # Fetches the list of users who favorited the photo with the given ID.
    # Example:
    #
    #     photo = Flickrie.get_photo_favorites(24810948)
    #     photo.favorites.first.username # => "John Smith"
    #
    # @param photo_id [String, Fixnum]
    # @return [Flickrie::Photo]
    # @api_method [flickr.photos.getFavorites](http://www.flickr.com/services/api/flickr.photos.getFavorites.html)
    def get_photo_favorites(photo_id, params = {})
      response = make_request(photo_id, params)
      Photo.new(response.body['photo'], self)
    end
    # Fetches the list of users who favorited the video with the given ID.
    # Example:
    #
    #     video = Flickrie.get_video_favorites(24810948)
    #     video.favorites.first.username # => "John Smith"
    #
    # @param video_id [String, Fixnum]
    # @return [Flickrie::Video]
    # @api_method [flickr.photos.getFavorites](http://www.flickr.com/services/api/flickr.photos.getFavorites.html)
    def get_video_favorites(video_id, params = {})
      response = make_request(video_id, params)
      Video.new(response.body['photo'], self)
    end

    # Fetches info of the photo/video with the given ID.
    #
    # @param media_id [String, Fixnum]
    # @return [Flickrie::Photo, Flickrie::Video]
    # @api_method [flickr.photos.getInfo](http://www.flickr.com/services/api/flickr.photos.getInfo.html)
    def get_media_info(media_id, params = {})
      response = make_request(media_id, params)
      Media.new(response.body['photo'], self)
    end
    alias get_photo_info get_media_info
    alias get_video_info get_media_info

    # Fetches photos and videos from the authenticated user
    # that are not in any set.
    #
    # @return [Flickrie::Collection<Flickrie::Photo, Flickrie::Video>]
    # @api_method [flickr.photos.getNotInSet](http://www.flickr.com/services/api/flickr.photos.getNotInSet.html)
    #
    # @note This method requires authentication with "read" permissions.
    def get_media_not_in_set(params = {})
      response = make_request({media: 'all'}.merge(params))
      Media.new_collection(response.body['photos'], self)
    end
    deprecated_alias :media_not_in_set, :get_media_not_in_set
    # Fetches photos from the authenticated user
    # that are not in any set.
    #
    # @return [Flickrie::Collection<Flickrie::Photo>]
    # @api_method [flickr.photos.getNotInSet](http://www.flickr.com/services/api/flickr.photos.getNotInSet.html)
    #
    # @note This method requires authentication with "read" permissions.
    def get_photos_not_in_set(params = {})
      get_media_not_in_set({media: "photos"}.merge(params))
    end
    deprecated_alias :photos_not_in_set, :get_photos_not_in_set
    # Fetches videos from the authenticated user
    # that are not in any set.
    #
    # @return [Flickrie::Collection<Flickrie::Video>]
    # @api_method [flickr.photos.getNotInSet](http://www.flickr.com/services/api/flickr.photos.getNotInSet.html)
    #
    # @note This method requires authentication with "read" permissions.
    def get_videos_not_in_set(params = {})
      get_media_not_in_set({media: "videos"}.merge(params))
    end
    deprecated_alias :videos_not_in_set, :get_videos_not_in_set

    # Gets permissions of a photo with the given ID.
    #
    # @return [Flickrie::Photo]
    # @api_method [flickr.photos.getPerms](http://www.flickr.com/services/api/flickr.photos.getPerms.html)
    #
    # @note This method requires authentication with "read" permissions.
    def get_photo_permissions(photo_id, params = {})
      response = make_request(photo_id, params)
      Photo.new(response.body['perms'], self)
    end
    # Gets permissions of a video with the given ID.
    #
    # @return [Flickrie::Video]
    # @api_method [flickr.photos.getPerms](http://www.flickr.com/services/api/flickr.photos.getPerms.html)
    #
    # @note This method requires authentication with "read" permissions.
    def get_video_permissions(video_id, params = {})
      response = make_request(video_id, params)
      Video.new(response.body['perms'], self)
    end

    # Fetches the latest photos and videos uploaded to Flickr.
    #
    # @return [Flickrie::Collection<Flickrie::Photo, Flickrie::Video>]
    # @api_method [flickr.photos.getRecent](http://www.flickr.com/services/api/flickr.photos.getRecent.html)
    def get_recent_media(params = {})
      response = make_request(params)
      Media.new_collection(response.body['photos'], self)
    end
    # Fetches the latest photos uploaded to Flickr.
    #
    # @return [Flickrie::Collection<Flickrie::Photo>]
    # @api_method [flickr.photos.getRecent](http://www.flickr.com/services/api/flickr.photos.getRecent.html)
    def get_recent_photos(params = {})
      get_recent_media(params).select { |media| media.is_a?(Photo) }
    end
    # Fetches the latest videos uploaded to Flickr.
    #
    # @return [Flickrie::Collection<Flickrie::Video>]
    # @api_method [flickr.photos.getRecent](http://www.flickr.com/services/api/flickr.photos.getRecent.html)
    def get_recent_videos(params = {})
      get_recent_media(params).select { |media| media.is_a?(Video) }
    end

    # Fetches the sizes of the photo with the given ID. Example:
    #
    #     photo = Flickrie.get_photo_sizes(242348)
    #     photo.medium!(500)
    #     photo.size       # => "Medium 500"
    #     photo.source_url # => "http://farm8.staticflickr.com/7090/7093101501_9337f28800.jpg"
    #
    # @param photo_id [String, Fixnum]
    # @return [Flickrie::Photo]
    # @api_method [flickr.photos.getSizes](http://www.flickr.com/services/api/flickr.photos.getSizes.html)
    def get_photo_sizes(photo_id, params = {})
      response = make_request(photo_id, params)
      Photo.new(response.body['sizes'], self)
    end
    # Fetches the sizes of the video with the given ID. Example:
    #
    #     video = Flickrie.get_video_sizes(438492)
    #     video.download_url # => "..."
    #
    # @param video_id [String, Fixnum]
    # @return [Flickrie::Video]
    # @api_method [flickr.photos.getSizes](http://www.flickr.com/services/api/flickr.photos.getSizes.html)
    def get_video_sizes(video_id, params = {})
      response = make_request(video_id, params)
      Video.new(response.body['sizes'], self)
    end

    # Fetches photos and videos from the authenticated user that have no
    # tags.
    #
    # @return [Flickrie::Collection<Flickrie::Photo, Flickrie::Video>]
    # @api_method [flickr.photos.getUntagged](http://www.flickr.com/services/api/flickr.photos.getUntagged.html)
    #
    # @note This method requires authentication with "read" permissions.
    def get_untagged_media(params = {})
      response = make_request({media: 'all'}.merge(params))
      Media.new_collection(response.body['photos'], self)
    end
    # Fetches photos from the authenticated user that have no tags.
    #
    # @return [Flickrie::Collection<Flickrie::Photo>]
    # @api_method [flickr.photos.getUntagged](http://www.flickr.com/services/api/flickr.photos.getUntagged.html)
    #
    # @note This method requires authentication with "read" permissions.
    def get_untagged_photos(params = {})
      get_untagged_media({media: 'photos'}.merge(params))
    end
    # Fetches videos from the authenticated user that have no tags.
    #
    # @return [Flickrie::Collection<Flickrie::Video>]
    # @api_method [flickr.photos.getUntagged](http://www.flickr.com/services/api/flickr.photos.getUntagged.html)
    #
    # @note This method requires authentication with "read" permissions.
    def get_untagged_videos(params = {})
      get_untagged_media({media: 'videos'}.merge(params))
    end

    # Fetches geo-tagged photos and videos from the authenticated user.
    #
    # @return [Flickrie::Collection<Flickrie::Photo, Flickrie::Video>]
    # @api_method [flickr.photos.getWithGeoData](http://www.flickr.com/services/api/flickr.photos.getWithGeoData.html)
    #
    # @note This method requires authentication with "read" permissions.
    def get_media_with_geo_data(params = {})
      response = make_request({media: 'all'}.merge(params))
      Media.new_collection(response.body['photos'], self)
    end
    # Fetches geo-tagged photos from the authenticated user.
    #
    # @return [Flickrie::Collection<Flickrie::Photo>]
    # @api_method [flickr.photos.getWithGeoData](http://www.flickr.com/services/api/flickr.photos.getWithGeoData.html)
    #
    # @note This method requires authentication with "read" permissions.
    def get_photos_with_geo_data(params = {})
      get_media_with_geo_data({media: 'photos'}.merge(params))
    end
    # Fetches geo-tagged videos from the authenticated user.
    #
    # @return [Flickrie::Collection<Flickrie::Video>]
    # @api_method [flickr.photos.getWithGeoData](http://www.flickr.com/services/api/flickr.photos.getWithGeoData.html)
    #
    # @note This method requires authentication with "read" permissions.
    def get_videos_with_geo_data(params = {})
      get_media_with_geo_data({media: 'videos'}.merge(params))
    end

    # Fetches photos and videos from the authenticated user that are not
    # geo-tagged.
    #
    # @return [Flickrie::Collection<Flickrie::Photo, Flickrie::Video>]
    # @api_method [flickr.photos.getWithoutGeoData](http://www.flickr.com/services/api/flickr.photos.getWithoutGeoData.html)
    #
    # @note This method requires authentication with "read" permissions.
    def get_media_without_geo_data(params = {})
      response = make_request({media: 'all'}.merge(params))
      Media.new_collection(response.body['photos'], self)
    end
    # Fetches photos from the authenticated user that are not geo-tagged.
    #
    # @return [Flickrie::Collection<Flickrie::Photo>]
    # @api_method [flickr.photos.getWithoutGeoData](http://www.flickr.com/services/api/flickr.photos.getWithoutGeoData.html)
    #
    # @note This method requires authentication with "read" permissions.
    def get_photos_without_geo_data(params = {})
      get_media_with_geo_data({media: 'photos'}.merge(params))
    end
    # Fetches videos from the authenticated user that are not geo-tagged.
    #
    # @return [Flickrie::Collection<Flickrie::Video>]
    # @api_method [flickr.photos.getWithoutGeoData](http://www.flickr.com/services/api/flickr.photos.getWithoutGeoData.html)
    #
    # @note This method requires authentication with "read" permissions.
    def get_videos_without_geo_data(params = {})
      get_media_with_geo_data({media: 'videos'}.merge(params))
    end

    # Fetches photos and videos from the authenticated user that have
    # recently been updated.
    #
    # @return [Flickrie::Collection<Flickrie::Photo, Flickrie::Video>]
    # @api_method [flickr.photos.recentlyUpdated](http://www.flickr.com/services/api/flickr.photos.recentlyUpdated.html)
    #
    # @note This method requires authentication with "read" permissions.
    def get_recently_updated_media(params = {})
      response = make_request(params)
      Media.new_collection(response.body['photos'], self)
    end
    deprecated_alias :recently_updated_media, :get_recently_updated_media
    # Fetches photos from the authenticated user that have recently been updated.
    #
    # @return [Flickrie::Collection<Flickrie::Photo>]
    # @api_method [flickr.photos.recentlyUpdated](http://www.flickr.com/services/api/flickr.photos.recentlyUpdated.html)
    #
    # @note This method requires authentication with "read" permissions.
    def get_recently_updated_photos(params = {})
      recently_updated_media(params).select { |media| media.is_a?(Photo) }
    end
    deprecated_alias :recently_updated_photos, :get_recently_updated_photos
    # Fetches videos from the authenticated user that have recently been updated.
    #
    # @return [Flickrie::Collection<Flickrie::Video>]
    # @api_method [flickr.photos.recentlyUpdated](http://www.flickr.com/services/api/flickr.photos.recentlyUpdated.html)
    #
    # @note This method requires authentication with "read" permissions.
    def get_recently_updated_videos(params = {})
      recently_updated_media(params).select { |media| media.is_a?(Video) }
    end
    deprecated_alias :recently_updated_videos, :get_recently_updated_videos

    # Remove the tag with the given ID
    #
    # @param tag_id [String]
    # @return [nil]
    # @api_method [flickr.photos.removeTag](http://www.flickr.com/services/api/flickr.photos.removeTag.html)
    #
    # @note This method requires authentication with "write" permissions.
    def untag_media(tag_id, params = {})
      make_request(tag_id, params)
      nil
    end
    deprecated_alias :remove_media_tag, :untag_media
    alias untag_photo untag_media
    deprecated_alias :remove_photo_tag, :untag_photo
    alias untag_video untag_media
    deprecated_alias :remove_video_tag, :untag_video

    # Fetches photos and videos matching a certain criteria.
    #
    # @return [Flickrie::Collection<Flickrie::Photo, Flickrie::Video>]
    # @api_method [flickr.photos.search](http://www.flickr.com/services/api/flickr.photos.search.html)
    def search_media(params = {})
      response = make_request({media: 'all'}.merge(params))
      Media.new_collection(response.body['photos'], self)
    end
    # Fetches photos matching a certain criteria.
    #
    # @return [Flickrie::Collection<Flickrie::Photo>]
    # @api_method [flickr.photos.search](http://www.flickr.com/services/api/flickr.photos.search.html)
    def search_photos(params = {})
      search_media({media: 'photos'}.merge(params))
    end
    # Fetches videos matching a certain criteria.
    #
    # @return [Flickrie::Collection<Flickrie::Video>]
    # @api_method [flickr.photos.search](http://www.flickr.com/services/api/flickr.photos.search.html)
    def search_videos(params = {})
      search_media({media: 'videos'}.merge(params))
    end

    # Sets the content type of a photo/video.
    #
    # @param media_id [String, Fixnum]
    # @param content_type [String, Fixnum]
    # @return [nil]
    # @api_method [flickr.photos.setContentType](http://www.flickr.com/services/api/flickr.photos.setContentType.html)
    #
    # @note This method requires authentication with "write" permissions.
    def set_media_content_type(media_id, content_type, params = {})
      make_request(media_id, content_type, params)
      nil
    end
    alias set_photo_content_type set_media_content_type
    alias set_video_content_type set_media_content_type

    # Sets dates for a photo/video.
    #
    # @param media_id [String, Fixnum]
    # @return [nil]
    # @api_method [flickr.photos.setDates](http://www.flickr.com/services/api/flickr.photos.setDates.html)
    #
    # @note This method requires authentication with "write" permissions.
    def set_media_dates(media_id, params = {})
      make_request(media_id, params)
      nil
    end
    alias set_photo_dates set_media_dates
    alias set_video_dates set_media_dates

    # Sets meta information for a photo/video.
    #
    # @param media_id [String, Fixnum]
    # @return [nil]
    # @api_method [flickr.photos.setMeta](http://www.flickr.com/services/api/flickr.photos.setMeta.html)
    #
    # @note This method requires authentication with "write" permissions.
    def set_media_meta(media_id, params = {})
      make_request(media_id, params)
      nil
    end
    alias set_photo_meta set_media_meta
    alias set_video_meta set_media_meta

    # Sets permissions for a photo/video.
    #
    # @param media_id [String, Fixnum]
    # @return [nil]
    # @api_method [flickr.photos.setPerms](http://www.flickr.com/services/api/flickr.photos.setPerms.html)
    #
    # @note This method requires authentication with "write" permissions.
    def set_media_permissions(media_id, params = {})
      make_request(media_id, params)
      nil
    end
    alias set_photo_permissions set_media_permissions
    alias set_video_permissions set_media_permissions

    # Sets the safety level of a photo/video.
    #
    # @param media_id [String, Fixnum]
    # @return [nil]
    # @api_method [flickr.photos.setSafetyLevel](http://www.flickr.com/services/api/flickr.photos.setSafetyLevel.html)
    #
    # @note This method requires authentication with "write" permissions.
    def set_media_safety_level(media_id, params = {})
      make_request(media_id, params)
      nil
    end
    alias set_photo_safety_level set_media_safety_level
    alias set_video_safety_level set_media_safety_level

    # Sets tags for a photo/video.
    #
    # @param tags [String] A space-delimited string with tags
    # @return [nil]
    # @api_method [flickr.photos.setTags](http://www.flickr.com/services/api/flickr.photos.setTags.html)
    #
    # @note This method requires authentication with "write" permissions.
    def set_media_tags(media_id, tags, params = {})
      make_request(media_id, tags, params)
      nil
    end
    alias set_photo_tags set_media_tags
    alias set_video_tags set_media_tags

    # Comment on a photo/video.
    #
    # @return [String] Comment's ID
    # @api_method [flickr.photos.comments.addComment](http://www.flickr.com/services/api/flickr.photos.comments.addComment.html)
    #
    # @note This method requires authentication with "write" permissions.
    def comment_media(media_id, comment, params = {})
      response = make_request(media_id, comment, params)
      response.body["comment"]["id"]
    end
    alias comment_photo comment_media
    alias comment_video comment_media

    # Delete a comment.
    #
    # @return [nil]
    # @api_method [flickr.photos.comments.deleteComment](http://www.flickr.com/services/api/flickr.photos.comments.deleteComment.html)
    #
    # @note This method requires authentication with "write" permissions.
    def delete_media_comment(comment_id, params = {})
      make_request(comment_id, params)
      nil
    end
    alias delete_photo_comment delete_media_comment
    alias delete_video_comment delete_media_comment

    # Edit a specific comment.
    #
    # @return [nil]
    # @api_method [flickr.photos.comments.editComment](http://www.flickr.com/services/api/flickr.photos.comments.editComment.html)
    #
    # @note This method requires authentication with "write" permissions.
    def edit_media_comment(comment_id, comment, params = {})
      make_request(comment_id, comment, params)
      nil
    end
    alias edit_photo_comment edit_media_comment
    alias edit_video_comment edit_media_comment

    # Get list of comments of a photo/video.
    #
    # @return [Array<Flickrie::Comment>]
    # @api_method [flickr.photos.comments.getList](http://www.flickr.com/services/api/flickr.photos.comments.getList.html)
    def get_media_comments(media_id, params = {})
      response = make_request(media_id, params)
      response.body["comments"]["comment"].map { |hash| Flickrie::Comment.new(hash, self) }
    end
    alias get_photo_comments get_media_comments
    alias get_video_comments get_media_comments

    # Get list of photos/videos that have been recently commented by
    # the contacts of the authenticated user.
    #
    # @return [Flickrie::Collection<Flickrie::Photo, Flickrie::Video>]
    # @api_method [flickr.photos.comments.getRecentForContacts](http://www.flickr.com/services/api/flickr.photos.comments.getRecentForContacts.html)
    #
    # @note This method requires authentication with "read" permissions.
    def get_recently_commented_media_from_contacts(params = {})
      response = make_request(params)
      Media.new_collection(response.body["photos"], self)
    end
    # Get list of photos that have been recently commented by
    # the contacts of the authenticated user.
    #
    # @return [Flickrie::Collection<Flickrie::Photo>]
    # @api_method [flickr.photos.comments.getRecentForContacts](http://www.flickr.com/services/api/flickr.photos.comments.getRecentForContacts.html)
    #
    # @note This method requires authentication with "read" permissions.
    def get_recently_commented_photos_from_contacts(params = {})
      get_recently_commented_media_from_contacts(params).select { |media| media.is_a?(Photo) }
    end
    # Get list of videos that have been recently commented by
    # the contacts of the authenticated user.
    #
    # @return [Flickrie::Collection<Flickrie::Video>]
    # @api_method [flickr.photos.comments.getRecentForContacts](http://www.flickr.com/services/api/flickr.photos.comments.getRecentForContacts.html)
    #
    # @note This method requires authentication with "read" permissions.
    def get_recently_commented_videos_from_contacts(params = {})
      get_recently_commented_media_from_contacts(params).select { |media| media.is_a?(Video) }
    end

    # Fetches all available types of licenses.
    #
    # @return [Array<Flickrie::License>]
    # @api_method [flickr.photos.licenses.getInfo](http://www.flickr.com/services/api/flickr.photos.licenses.getInfo.html)
    def get_licenses(params = {})
      response = make_request(params)
      License.from_hash(response.body['licenses']['license'])
    end

    # Sets the license of a photo/video.
    #
    # @return [nil]
    # @api_method [flickr.photos.licenses.setLicense](http://www.flickr.com/services/api/flickr.photos.licenses.setLicense.html)
    #
    # @note This method requires authentication with "write" permissions.
    def set_media_license(media_id, license_id, params = {})
      make_request(media_id, license_id, params)
      nil
    end
    alias set_photo_license set_media_license
    alias set_video_license set_media_license

    # Rotates a photo/video.
    #
    # @return [nil]
    # @api_method [flickr.photos.transform.rotate](http://www.flickr.com/services/api/flickr.photos.transform.rotate.html)
    #
    # @note This method requires authentication with "write" permissions.
    def rotate_media(media_id, degrees, params = {})
      make_request(media_id, degrees, params)
      nil
    end
    alias rotate_photo rotate_media
    alias rotate_video rotate_media

    # Fetches upload tickets with given IDs. Example:
    #
    #     photo = File.open("...")
    #     ticket_id = Flickrie.upload(photo, async: 1)
    #     sleep(10)
    #
    #     ticket = Flickrie.check_upload_tickets(ticket_id)
    #     if ticket.complete?
    #       puts "Photo was uploaded, and its ID is #{ticket.photo_id}"
    #     end
    #
    # @param tickets [String] A space delimited string with ticket IDs
    # @return [Flickrie::Ticket]
    # @api_method [flickr.photos.upload.checkTickets](http://www.flickr.com/services/api/flickr.photos.upload.checkTickets.html)
    def check_upload_tickets(tickets, params = {})
      ticket_ids = tickets.join(',') rescue tickets
      response = make_request(ticket_ids, params)
      response.body['uploader']['ticket'].
        map { |info| Ticket.new(info) }
    end

    # Adds existing photo/video to a set with the given ID.
    #
    # @param set_id [Fixnum, String]
    # @return [nil]
    # @api_method [flickr.photosets.addPhoto](http://www.flickr.com/services/api/flickr.photosets.addPhoto.html)
    #
    # @note This method requires authentication with "write" permissions.
    def add_media_to_set(set_id, media_id, params = {})
      make_request(set_id, media_id, params)
    end
    alias add_photo_to_set add_media_to_set
    alias add_video_to_set add_media_to_set

    # Creates a new set.
    #
    # @return [Flickrie::Set]
    # @api_method [flickr.photosets.create](http://www.flickr.com/services/api/flickr.photosets.create.html)
    #
    # @note This method requires authentication with "write" permissions.
    def create_set(params = {})
      response = make_request(params)
      Set.new(response.body['photoset'], self)
    end

    # Deletes a set.
    #
    # @param set_id [Fixnum, String]
    # @return [nil]
    # @api_method [flickr.photosets.delete](http://www.flickr.com/services/api/flickr.photosets.delete.html)
    #
    # @note This method requires authentication with "write" permissions.
    def delete_set(set_id, params = {})
      make_request(set_id, params)
      nil
    end

    # Modifies metadata of a set.
    #
    # @param set_id [Fixnum, String]
    # @return [nil]
    # @api_method [flickr.photosets.editMeta](http://www.flickr.com/services/api/flickr.photosets.editMeta.html)
    #
    # @note This method requires authentication with "write" permissions.
    def edit_set_metadata(set_id, params = {})
      make_request(set_id, params)
      nil
    end

    # Edits photos/videos of a set with the given ID.
    #
    # @param set_id [Fixnum, String]
    # @return [nil]
    # @api_method [flickr.photosets.editPhotos](http://www.flickr.com/services/api/flickr.photosets.editPhotos.html)
    #
    # @note This method requires authentication with "write" permissions.
    def edit_set_media(set_id, params = {})
      make_request(set_id, params)
      nil
    end
    alias edit_set_photos edit_set_media
    alias edit_set_videos edit_set_media

    # Returns next and previous photos/videos for a photo/video in a set
    #
    # @return [Flickrie::MediaContext]
    # @api_method [flickr.photosets.getContext](http://www.flickr.com/services/api/flickr.photosets.getContext.html)
    def get_set_context(set_id, media_id, params = {})
      response = make_request(set_id, media_id, params)
      MediaContext.new(response.body, self)
    end

    # Fetches information about the set with the given ID.
    #
    # @return [Flickrie::Set]
    # @api_method [flickr.photosets.getInfo](http://www.flickr.com/services/api/flickr.photosets.getInfo.html)
    def get_set_info(set_id, params = {})
      response = make_request(set_id, params)
      Set.new(response.body['photoset'], self)
    end

    # Fetches sets from a user with the given NSID.
    #
    # @return [Flickrie::Collection<Flickrie::Set>]
    # @api_method [flickr.photosets.getList](http://www.flickr.com/services/api/flickr.photosets.getList.html)
    def get_sets_from_user(nsid, params = {})
      response = make_request(nsid, params)
      Set.new_collection(response.body['photosets'], self)
    end
    deprecated_alias :sets_from_user, :get_sets_from_user

    # Fetches photos and videos from a set with the given ID.
    #
    # @return [Flickrie::Collection<Flickrie::Photo, Flickrie::Video>]
    # @api_method [flickr.photosets.getPhotos](http://www.flickr.com/services/api/flickr.photosets.getPhotos.html)
    def get_media_from_set(set_id, params = {})
      response = make_request(set_id, {media: 'all'}.merge(params))
      Media.new_collection(response.body['photoset'], self)
    end
    deprecated_alias :media_from_set, :get_media_from_set
    # Fetches photos from a set with the given ID.
    #
    # @return [Flickrie::Collection<Flickrie::Photo>]
    # @api_method [flickr.photosets.getPhotos](http://www.flickr.com/services/api/flickr.photosets.getPhotos.html)
    def get_photos_from_set(set_id, params = {})
      get_media_from_set(set_id, {media: 'photos'}.merge(params))
    end
    deprecated_alias :photos_from_set, :get_photos_from_set
    # Fetches videos from a set with the given ID.
    #
    # @return [Flickrie::Collection<Flickrie::Video>]
    # @api_method [flickr.photosets.getPhotos](http://www.flickr.com/services/api/flickr.photosets.getPhotos.html)
    def get_videos_from_set(set_id, params = {})
      get_media_from_set(set_id, {media: 'videos'}.merge(params))
    end
    deprecated_alias :videos_from_set, :get_videos_from_set

    # Sets the order of sets belonging to the authenticated user.
    #
    # @param set_ids [String] A comma delimited list of set IDs
    # @return [nil]
    # @api_method [flickr.photosets.orderSets](http://www.flickr.com/services/api/flickr.photosets.orderSets.html)
    #
    # @note This method requires authentication with "write" permissions.
    def order_sets(set_ids, params = {})
      make_request(set_ids, params)
      nil
    end

    # Removes photos/videos from a set.
    #
    # @param media_ids [String] A comma delimited list of photo/video IDs
    # @return [nil]
    # @api_method [flickr.photosets.removePhotos](http://www.flickr.com/services/api/flickr.photosets.removePhotos.html)
    #
    # @note This method requires authentication with "write" permissions.
    def remove_media_from_set(set_id, media_ids, params = {})
      make_request(set_id, media_ids, params)
      nil
    end
    alias remove_photos_from_set remove_media_from_set
    alias remove_videos_from_set remove_media_from_set

    # Reorders photos/videos inside a set.
    #
    # @param media_ids [String] A comma delimited list of photo/video IDs
    # @return [nil]
    # @api_method [flickr.photosets.reorderPhotos](http://www.flickr.com/services/api/flickr.photosets.reorderPhotos.html)
    #
    # @note This method requires authentication with "write" permissions.
    def reorder_media_in_set(set_id, media_ids, params = {})
      make_request(set_id, media_ids, params)
      nil
    end
    alias reorder_photos_in_set reorder_media_in_set
    alias reorder_videos_in_set reorder_media_in_set

    # Sets set's primary photo/video.
    #
    # @return [nil]
    # @api_method [flickr.photosets.setPrimaryPhoto](http://www.flickr.com/services/api/flickr.photosets.setPrimaryPhoto.html)
    #
    # @note This method requires authentication with "write" permissions.
    def set_set_primary_media(set_id, media_id, params = {})
      make_request(set_id, media_id, params)
      nil
    end
    deprecated_alias :set_primary_media_to_set, :set_set_primary_media
    alias set_set_primary_photo set_set_primary_media
    deprecated_alias :set_primary_photo_to_set, :set_set_primary_photo
    alias set_set_primary_video set_set_primary_media
    deprecated_alias :set_primary_video_to_set, :set_set_primary_video

    # Fetches the list of all API methods.
    #
    # @return [Array<String>]
    # @api_method [flickr.reflection.getMethods](http://www.flickr.com/services/api/flickr.reflection.getMethods.html)
    def get_methods(params = {})
      response = make_request(params)
      response.body["methods"]["method"]
    end

    # Tests if the authentication was successful. If it was, it
    # returns info of the user who just authenticated.
    #
    # @return [Flickrie::User]
    # @api_method [flickr.test.login](http://www.flickr.com/services/api/flickr.test.login.html)
    #
    # @note This method requires authentication with "read" permissions.
    def test_login(params = {})
      response = make_request(params)
      User.new(response.body['user'], self)
    end

    private

    def make_request(*args)
      method = caller.first[/`.*'/][1..-2]
      if ["upload", "replace"].include?(method)
        upload_client.send(method, *args)
      else
        client.send(method, *args)
      end
    end
  end
end
