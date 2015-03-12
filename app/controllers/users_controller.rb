class UsersController < ApplicationController

  before_filter :get_user


  def show
    respond_to do |format|
      format.html { render :show }
    end
  end


private

  def get_user
    @user = User.find(params[:id])
    raise ActvieRecord::RecordNotFound
  end

end
