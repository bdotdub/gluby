module Gluby

  # This class represents an Object in Glue. An instance of this class can
  # only be instantiated by on of the factory methods
  class Object
    extend LazyLoader
    attr_reader :objectKey
    lazy_load   [:title, :image, :link, :type, :description], :get

    def initialize(objectKey)
      @objectKey = objectKey
    end

    # Makes a call to the Glue API to get the object info. Returns nil if it
    # cannot find an object
    def self.get(objectId)
      begin
        response = Gluby.get("/object/get", :query => { :objectId => objectId })
        from_object(response)
      rescue Gluby::InvalidObject
        nil
      end
    end

    def self.from_object(response)
      raise ArgumentError if not response.instance_of?(Gluby::AdaptiveBlueResponse)

      object_xml  = response.response['object']
      type        = object_xml['type']
      objectKey   = object_xml['objectKey']
      object      = create_for_type(objectKey, type)

      assign_variables_from_response(object, response)
      object
    end

    def self.from_interaction(response)
      objectKey   = response['objectKey']
      type        = response['category']
      object      = create_for_type(objectKey, type)

      %w[title image objectKey].each do |property|
        object.instance_variable_set("@#{property}", response[property])  
      end

      object.instance_variable_set("@type", type)
      object.instance_variable_set("@link", response['source']['link'])

      object
    end

    def get
      response = Gluby.get("/object/get", :query => { :objectId => @objectKey })
      self.class.assign_variables_from_response(self, response)
    end

    def users
      response = Gluby.get("/object/users", :query => { :objectId => @objectKey })
      Gluby::Interaction.from_response(response)
    end

    def links
      response = Gluby.get("/object/links", :query => { :objectId => @objectKey })
      response.response['links']['link']
    end

    def visit
      response = Gluby.get("/user/addVisit", :query => { :objectId => @objectKey, :source => Gluby::GLUE_SOURCE, :app => Gluby::GLUE_APP })
      Gluby::Interaction.from_response(response)
    end

    def unvisit
      response = Gluby.get("/user/removeVisit", :query => { :objectId => @objectKey })
      return :success if response.response.has_key?('success')
    end

    def like
      response = Gluby.get("/user/addLike", :query => { :objectId => @objectKey, :source => Gluby::GLUE_SOURCE, :app => Gluby::GLUE_APP })
      Gluby::Interaction.from_response(response)
    end

    def unlike
      response = Gluby.get("/user/removeLike", :query => { :objectId => @objectKey })
      return :success if response.response.has_key?('success')
    end

    def add2cents(comment)
      raise Gluby::TooManyCharacters if comment.length > 160

      response = Gluby.get("/user/add2Cents", :query => { :objectId => @objectKey, :source => Gluby::GLUE_SOURCE, :app => Gluby::GLUE_APP, :comment => comment })
      Gluby::Interaction.from_response(response)
    end

    def remove2cents
      response = Gluby.get("/user/remove2Cents", :query => { :objectId => @objectKey })
      return :success if response.response.has_key?('success')
    end

    def glue_object?
      false
    end

    protected

    def self.create_for_type(objectKey, type)
      # Would've extracted this out into a constant, but the classes
      # are not defined and throws NameErrors
	    @@categories = {
	      :books              => Gluby::BookObject,
	      :electronics        => Gluby::ElectronicObject,
	      :movie_stars        => Gluby::MovieStarObject,
	      :movies             => Gluby::MovieObject,
	      :music              => Gluby::MusicObject,
	      :recording_artists  => Gluby::RecordingArtistObject,
	      :restaurants        => Gluby::RestaurantObject,
	      :stocks             => Gluby::StockObject,
	      :tv_shows           => Gluby::TVShowObject,
	      :video_games        => Gluby::VideoGameObject,
	      :wines              => Gluby::WineObject,
        :bookmarks          => Gluby::BookmarkObject
	    }

      if type.kind_of?(Array)
        types = type.select do |type|
          @@categories.has_key?(type.to_sym) &&
          type != "bookmarks"
        end

        type = (types.length == 1) ? types[0] : nil
      end
      
      if !type.nil? && @@categories.has_key?(type.to_sym)
        @@categories[type.to_sym].new(objectKey)
      else
        new(objectKey)
      end
    end

    def self.assign_variables_from_response(object, response)
      response.response['object'].each do |property, value|
        object.instance_variable_set(:"@#{property.to_s}", value)
      end
    end
  end

  class GlueObject < Object
    def glue_object?; true; end
  end

  class BookObject < GlueObject
  end

  class ElectronicObject < GlueObject
  end

  class MovieStarObject < GlueObject
  end

  class MovieObject < GlueObject
    lazy_load [:director, :year, :starring], :get
  end

  class MusicObject < GlueObject
  end

  class RecordingArtistObject < GlueObject
  end

  class RestaurantObject < GlueObject
  end

  class StockObject < GlueObject
  end

  class TVShowObject < GlueObject
  end

  class VideoGameObject < GlueObject
  end

  class WineObject < GlueObject
  end

  class BookmarkObject < Object
  end

end
