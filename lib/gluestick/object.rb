module Gluestick
  class Object
    extend LazyLoader
  
    private_class_method  :new
    attr_reader           :objectKey, :title, :image, :link, :type    

    def self.get(objectId)
      begin
        response = Gluestick.get("/object/get", :query => { :objectId => objectId })
        from_object(response)
      rescue Gluestick::InvalidObject
        nil
      end
    end

    def self.from_object(response)
      raise TypeError if not response.instance_of?(Gluestick::AdaptiveBlueResponse)

      object_xml  = response.response['object']
      object      = create_for_type(object_xml['type'])

      assign_variables_from_response(object, response)
      object
    end

    def self.from_interaction(response)
      type        = response['category']
      object      = create_for_type(type)

      %w[title image objectKey].each do |property|
        object.instance_variable_set("@#{property}", response[property])  
      end

      object.instance_variable_set("@type", type)
      object.instance_variable_set("@link", response['source']['link'])

      object
    end

    def get
      response = Gluestick.get("/object/get", :query => { :objectId => @objectKey })
      self.class.assign_variables_from_response(self, response)
    end

    def users
      response = Gluestick.get("/object/users", :query => { :objectId => @objectKey })
      Gluestick::Interaction.from_response(response)
    end

    def links
      response = Gluestick.get("/object/links", :query => { :objectId => @objectKey })
      response.response['links']['link']
    end

    protected

    def self.create
      new
    end

    def self.create_for_type(type)
      # Would've extracted this out into a constant, but the classes
      # are not defined and throws NameErrors
	    @@categories = {
	      :books               => Gluestick::BookObject,
	      :electronics         => Gluestick::ElectronicObject,
	      :movie_stars         => Gluestick::MovieStarObject,
	      :movies              => Gluestick::MovieObject,
	      :music               => Gluestick::MusicObject,
	      :recording_artists   => Gluestick::RecordingArtistObject,
	      :restaurants         => Gluestick::RestaurantObject,
	      :stocks              => Gluestick::StockObject,
	      :tv_shows            => Gluestick::TVShowObject,
	      :video_games         => Gluestick::VideoGameObject,
	      :wines               => Gluestick::WineObject
	    }
      
      if @@categories.has_key?(type.to_sym)
        @@categories[type.to_sym].create
      else
        create
      end
    end

    def self.assign_variables_from_response(object, response)
      response.response['object'].each do |property, value|
        object.instance_variable_set(:"@#{property.to_s}", value)
      end
    end
  end

  class BookObject < Object
  end

  class ElectronicObject < Object
  end

  class MovieStarObject < Object
  end

  class MovieObject < Object
    lazy_load [:director, :year, :starring], :get
  end

  class MusicObject < Object
  end

  class RecordingArtistObject < Object
  end

  class RestaurantObject < Object
  end

  class StockObject < Object
  end

  class TVShowObject < Object
  end

  class VideoGameObject < Object
  end

  class WineObject < Object
  end


end
