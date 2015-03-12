# require "will_paginate/view_helpers/action_view"
# 
# 
# # Customized More Button
# module MoreButtonPagination
# 
#   class Rails < WillPaginate::ActionView::LinkRenderer
# 
#     # Add nofollow to will_paginate links
#     def rel_value(page)
#       [super, 'nofollow'].compact.join(' ')
#     end
# 
#     def prepare(collection, options, template)
#       if defined? ::I18n
#         ::I18n.backend.store_translations(:en, will_paginate: {more_label: "More"}) unless (::I18n.translate(:more_label, scope: [:will_paginate], raise: true) rescue false)
#       end
#       
#       super(collection, options, template)
#     end
# 
#     def to_html
#       list_items = pagination.map do |item|
#         case item
#           when Fixnum
#             page_number(item)
#           else
#             send(item)
#         end
#       end.join(@options[:link_separator])
# 
#       tag("ul", list_items, class: ul_class)
#     end
# 
#     def container_attributes
#       super.except(*[:link_options])
#     end
# 
#   protected
# 
#     def page_number(page); end
# 
#     def previous_or_next_page(page, text, classname)
#       link_options = @options[:link_options] || {}
#       link_options[:rel]
# 
#       if page
#         tag("li", link(text, page, link_options), class: classname)
#       else
#         tag("li", tag("span", text), class: "%s disabled" % classname)
#       end
#     end
# 
#     def gap; end
#     def previous_page; end
# 
#     def next_page
#       num = @collection.current_page < @collection.total_pages && @collection.current_page + 1
#       more_label = @options[:more_label] || @template.will_paginate_translate(:more_label) { "More" }
#       previous_or_next_page(num, more_label, "next more")
#     end
# 
#     def ul_class
#       ["pagination", @options[:class]].compact.join(" ")
#     end
#   end
# 
# end