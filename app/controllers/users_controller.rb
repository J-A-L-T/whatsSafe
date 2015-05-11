class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy, :data]

  # # GET /contacts
  # # GET /contacts.json
  # def index
  #   @contacts = Contact.all

  #   # Search
  #   @contacts = @contacts.search(params[:q]) if params[:q]

  #   # Filter for relationship
  #   @contacts = @contacts.relationship(params[:relationship]) if params[:relationship]

  #   # Order by
  #   @contacts = @contacts.order(params[:order].gsub(':', ' ')) if params[:order]

  #   # Pagination
  #   if (params[:offset] && params[:limit])
  #     @contacts = @contacts.page(1).per(params[:limit]).padding(params[:offset])
  #   else
  #     @contacts = @contacts.page(1).per(25)
  #   end


  #   render json: @contacts if stale?(etag: @contacts.all, last_modified: @contacts.maximum(:updated_at))
  # end

  def data
    render json: @user = User.find(params[:id]) 
  end

  def pubkey
    render json: @user = User.find(params[:id]) 
  end

  def create
    @user = User.new(user_params)

    if @user.save
      render json: @user, status: :created
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