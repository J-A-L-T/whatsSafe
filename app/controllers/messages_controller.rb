class MessagesController < ApplicationController
  before_action :set_message, only: [:show, :update, :destroy]

  def create
    @outerMessage = OuterMessage.new(outer_message_params)
    @outerMessage.id_recipient = params[:id_recipient]

    if (Time.now.to_i-@outerMessage.timestamp) > 300
      render json: {"status"=> "1", "Error"=> "Message is older than 5 minutes"}, status: 1
    else
      @message = Message.new( :id_recipient => params[:id_recipient],
                              :id_sender => @outerMessage.id_sender,
                              :cipher => @outerMessage.cipher,
                              :iv => @outerMessage.iv,
                              :key_recipient_enc => @outerMessage.key_recipient_enc,
                              :sig_recipient => @outerMessage.sig_recipient,)
      if @message.save 
        render json: @message, :only => [:id_recipient ,:id_sender, :cipher, :iv, :key_recipient_enc, :sig_recipient], status: :created
      else
        render json: @message.errors, status: :unprocessable_entity
      end
    end
  end

  def recieve
    @messages = Message.where(:id_recipient => params[:id_recipient])
    render json: @messages, :only => [:id_sender, :cipher, :iv, :key_recipient_enc, :sig_recipient]
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_message
      @Message = Message.find(params[:id_recipient])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def outer_message_params
      params.require(:outerMessage).permit(:timestamp, :sig_service, :id_sender, :cipher, :iv, :key_recipient_enc, :sig_recipient)
    end
end