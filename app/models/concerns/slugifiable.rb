module Slugifiable

    module InstanceMethods
      def slug
          slug = self.name.downcase.parameterize
      end
end

    module ClassMethods
      def find_by_slug(slug)
          @slug = slug
          format_slug_beginning
          results = self.where("name LIKE ?", @short_slug)
          results.detect do |result|
            result.slug === @slug
          end
        end
      
        def format_slug_beginning
          slug_beginning = @slug.split("-")[0]
          slug_beginning.prepend("%")
          slug_beginning << "%"
          @short_slug = slug_beginning
        end
    end
 
end