class SessionsController < ApplicationController

  include Facebook::Messenger

  def new
    id = params["messenger_id"]
    redirect_to "/auth/facebook?messenger_id=#{id}"
  end

  def create
    auth = request.env["omniauth.auth"]
    paramz = request.env["omniauth.params"]
    user = User.where(:provider => auth['provider'], :uid => auth['uid'].to_s).first || User.create_with_omniauth(auth, paramz["messenger_id"])
    reset_session
    session[:user_id] = user.id
    redirect_to "https://www.facebook.com/Job-Hunter-867755793387240"
    user.say_hi
  end

  def destroy
    reset_session
    redirect_to root_url, :notice => 'Signed out!' # handled by facebook
  end

  def failure
    redirect_to root_url, :alert => "Authentication error: #{params[:message].humanize}"
  end

end
