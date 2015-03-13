class UsersController < ApplicationController

  before_filter :get_user


  def show
    respond_to do |format|
      format.html {
        @latest_colors = @user.colors.order('created_at desc').limit(100)
        render :show
      }
    end
  end


private

  def get_user
    @user = User.find(params[:id])
    raise ActiveRecord::RecordNotFound if @user.blank?
  end

end
