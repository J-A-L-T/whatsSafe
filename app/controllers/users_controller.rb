class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy, :data]

 def data
    @user = User.find(params[:id]) 
    render json: @user, :only => [:salt_masterkey, :pubkey_user, :privkey_user_enc]
  end

  def pubkey
    @user = User.find(params[:id]) 
    render json: @user, :only => [:pubkey_user]
  end

  def create
    @user = User.new(user_params)

    if @user.save 
    render json: @user, :only => [:id], status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # # PATCH/PUT /contacts/1
  # # PATCH/PUT /contacts/1.json
  # def update
  #   if @contact.update(contact_params)
  #     head :no_content
  #   else
  #     render json: @contact.errors, status: :unprocessable_entity
  #   end
  # end

  # # DELETE /contacts/1
  # # DELETE /contacts/1.json
  # def destroy
  #   @contact.destroy

  #   head :no_content
  # end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @User = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:salt_masterkey, :pubkey_user, :privkey_user_enc)
    end
end