class UserSessionsController < ApplicationController

  before_filter :authenticate_user!, only: [:destroy]


  def new
    render :new
  end

  def destroy
    @user_session = UserSession.find
    @user_session.destroy
    redirect_to root_url
  end


private


end
