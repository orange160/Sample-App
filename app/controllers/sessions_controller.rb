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

  def weibo_login
    code = params[:code]

    url = "https://api.weibo.com/"
    opts = {}
    opts['client_id'] = ENV['WEIBO_APPKEY']
    opts['client_secret'] = ENV['WEIBO_APPSECRET']
    opts['grant_type'] = 'authorization_code'
    opts['redirect_uri'] = '39.106.184.102/weibologin'
    opts['code'] = code

    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    http.start do |http|
      req = Net::HTTP::Post.new('/oauth2/access_token')
      req.set_form_data(opts)
      resp = http.request(req).body
      logger.info(resp)
    end



    redirect_to root_path
  end

end
