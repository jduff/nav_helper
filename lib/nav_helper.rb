module NavHelper
  # Example Useage:
  # <%navigation do |nav|%>
  #   <%if logged_in? %>
  #     <%=nav.item :logout%>
  #     <%=nav.item :posts, :link=>user_posts_url(current_user), 
  #                 :selected_if=>Proc.new {|controller| controller.controller_name.to_sym == :posts}%>
  #   <%else%>
  #     <%=nav.item :signup%> #uses the signup_url helper
  #     <%=nav.item :login%>  #uses the login_url helper
  #   <%end%>
  # <%end%>
  
  # Example Output:
  # <ul class='nav_bar'>
  #   <li><a href='/logout'>Logout</a></li>
  #   <li class='current'><a href='/user/1/posts'>Posts</a></li>
  #   <li class='clear'></li>
  # </ul>
  
  def navigation(*args, &block)
    raise ArgumentError, "Missing block" unless block_given?
    Navigation.new(self, args.extract_options!).generate(&block)
  end

  class Navigation
    def initialize(view, options)
      @view = view
      @opts = options
      @opts[:nav_class] ||= 'nav_bar'
      @opts[:current_class] ||= 'current'
      @opts[:wrapper_tag] ||= 'ul'
    end

    def item(title, *args)
      opts = args.extract_options!
      opts[:link] ||= @view.send("#{title.to_s.downcase}_path")
      opts[:tag] ||= :li
      css = selected?(opts[:link], title.to_sym, opts[:selected_if]) ? @opts[:current_class] : nil
      @view.content_tag(opts[:tag], @view.link_to(title.to_s.titleize, opts[:link]), :class => css)
    end

    def generate(&block)
      @view.concat("<#{@opts[:wrapper_tag]} class='#{@opts[:nav_class]}'>")
      yield self
      @view.concat("</#{@opts[:wrapper_tag]}>")
    end

    private
    def selected?(link, title, condition=nil)
      if condition
        condition.call(@view.controller)
      else
        request = @view.request
        uri = request.request_uri
        title == @view.controller.controller_name.to_sym || link == @view.controller.controller_name.to_sym || link == uri || link == "#{request.protocol}#{request.host_with_port}#{uri}"
      end
    end
  end
end