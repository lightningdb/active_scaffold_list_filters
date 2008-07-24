module ActiveScaffold::Actions
  module ListFilter
	
    def self.included(base)
      base.before_filter :list_filter_authorized?, :only => [:list_filter]
      base.before_filter :init_filter_session_var
	    base.before_filter :do_list_filter
	    
      as_list_filter_plugin_path = File.join(RAILS_ROOT, 'vendor', 'plugins', as_list_filter_plugin_name, 'frontends', 'default', 'views')
      if base.respond_to?(:generic_view_paths) && ! base.generic_view_paths.empty?
        base.generic_view_paths.insert(0, as_list_filter_plugin_path)
      else
        config.inherited_view_paths << as_list_filter_plugin_path
      end
    end
      
    def self.as_list_filter_plugin_name
      # extract the name of the plugin as installed
      /.+vendor\/plugins\/(.+)\/lib/.match(__FILE__)
      plugin_name = $1	    
    end

    def init_filter_session_var
			if !params["list_filter"].nil?
				if params["list_filter"]["input"] == "filter"
			  	active_scaffold_session_storage["list_filter"] = params["list_filter"]
				elsif params["list_filter"]["input"] == "reset"
					active_scaffold_session_storage["list_filter"] = nil
				end
			end
    end

    def list_filter
      filter_config = active_scaffold_config.list_filter
	    respond_to do |wants|
        wants.html do
          if successful?
            render(:partial => 'list_filter', :locals => { :filter_config => filter_config }, :layout => true)
          else
            return_to_main
          end
        end
        wants.js do
          render(:partial => 'list_filter', :locals => { :filter_config => filter_config }, :layout => false)
        end
      end
    end
		

    protected

    def do_list_filter
			list_session = active_scaffold_session_storage["list_filter"]
			unless list_session.nil?
				active_scaffold_config.list_filter.filters.each do |filter|
					unless list_session[filter.filter_type].nil? || list_session[filter.filter_type][filter.name].nil?
						conditions = filter.conditions(list_session[filter.filter_type][filter.name])
						self.active_scaffold_conditions = merge_conditions(self.active_scaffold_conditions, conditions)
						active_scaffold_config.list.user.page = nil
					end
				end
			end
    end

		def clear_list_filter
				active_scaffold_session_storage[:list_filter] = nil?
				active_scaffold_config.list.user.page = nil
		end

    # The default security delegates to ActiveRecordPermissions.
    # You may override the method to customize.
    def list_filter_authorized?
      authorized_for?(:action => :read)
    end
  end
end