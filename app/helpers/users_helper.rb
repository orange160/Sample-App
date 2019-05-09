module UsersHelper
  #返回指定用户的Gravatar
  def gravatar_for(user, options = {size: 80})
    if user.login_type == 'weibo'
      gravatar_url = user.avatar_url
      image_tag(gravatar_url, alt: user.name, class: "gravatar", size: "50x50")
    else
      gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
      size = options[:size]
      gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
      image_tag(gravatar_url, alt: user.name, class: "gravatar")
    end
  end
end
