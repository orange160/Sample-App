require 'net/https'
require 'uri'

class SessionsController < ApplicationController


  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      if user.activated?
        log_in user
        params[:session][:remember_me] == '1' ? remember(user) : forget(user)
        redirect_back_or user
      else 
        message = "Account not activated. "
        message += "Check your email for the activation link."
        flash[:warning] = message
        redirect_to root_url
      end
    else
      flash.now[:danger] = "Invalid email/password combination" #不完全正确
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_path
  end

  # Get access token by post method with code
  def weibo_get_accesstoken(code)
    ret = {}
    opts = {}
    opts['client_id'] = ENV['WEIBO_APPKEY']
    opts['client_secret'] = ENV['WEIBO_APPSECRET']
    opts['grant_type'] = 'authorization_code'
    opts['redirect_uri'] = ENV['WEIBO_RE_URI']
    opts['code'] = code

    uri = URI.parse('https://api.weibo.com/')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    http.start do |http|
      req = Net::HTTP::Post.new('/oauth2/access_token')
      req.set_form_data(opts)

      resp = http.request(req).body  #post方式
      ret = JSON.parse(resp)
    end
    ret
  end

  # Get the weibo authorization user's information
  def weibo_get_userInfo(access_token, uid)
    url = "https://api.weibo.com/2/users/show.json?uid=#{uid}&access_token=#{access_token}"
    uri = URI(url)
    resp = Net::HTTP.get(uri)
    JSON.parse(resp)
  end

  def weibo_login
    @userInfo = nil
    resp = weibo_get_accesstoken(params[:code])
    access_token = resp['access_token']
    uid = resp['uid']
    expires_in = resp['expires_in']

    logger.info("access token: " + access_token + "====" + expires_in.to_s)

    if access_token != nil
      @userInfo = weibo_get_userInfo(access_token, uid)
    end


    #redirect_to root_path
  end

end
