module ActiveScaffold
	module Helpers
		# A bunch of helper methods to produce the common view ids
    module Ids
			def list_filter_form_id
        "#{controller_id}-list_filter-form"
      end
			def list_filter_input_id(filter)
        "#{controller_id}-list_filter-input[#{filter.filter_type}][#{filter.name}]"
      end
			def list_filter_input_name(filter)
				"list_filter[#{filter.filter_type}][#{filter.name}]"
			end
		end
	end
end