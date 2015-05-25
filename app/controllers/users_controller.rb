class UsersController < ApplicationController

  before_filter :get_user, only: [:show]
  before_filter :authenticate_user!, only: [:edit,:update]


  def show
    respond_to do |format|
      format.html {
        @latest_colors = @user.page_colors.order('created_at desc').limit(100)
        render :show
      }
    end
  end

  def edit
    respond_to do |format|
      format.html {
        render :edit
      }
    end
  end

  def update
    results = ->{
      current_user.update(user_update_params)
    }

    respond_to do |format|
      format.html {
        if results.call
          redirect_to user_settings_url
        else
          render :edit
        end
      }
    end
  end

private

  def get_user
    @user = User.find(params[:id])
    raise ActiveRecord::RecordNotFound if @user.blank?
  end

  def user_update_params
    params.require(:user).permit(:name, :email)
  end

end
