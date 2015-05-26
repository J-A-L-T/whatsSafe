class MessagesController < ApplicationController
  before_action :set_message, only: [:show, :update, :destroy]

  def create
    # Prüfung der Nachricht mit 
    # Der Dienstanbieter authentifiziert den äußeren Umschlag
    # mit Hilfe von sig_service und dem pubkey_user der angegeben Identitätt im inneren Umschlag.
    @outerMessage = OuterMessage.new(outer_message_params)
    @outerMessage.id_recipient = params[:id_recipient]

    if (Time.now.to_i-@outerMessage.timestamp) > 300
      render json: {"status"=> "1", "Error"=> "Request is older than 5 minutes"}, status: 1
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
    # Wie werden Parameter per GET mitgeschickt?
    # Prüfung des Nachrichtenabrufs
    # Authentifizierung mit id und Signatur
    # Prüfung: Alter < 300 Sekunden
    # if (Time.now.to_i-@outerMessage.timestamp) > 300
    #  render json: {"status"=> "1", "Error"=> "Request is older than 5 minutes"}, status: 1
    # else
    @messages = Message.where(:id_recipient => params[:id_recipient])
    render json: @messages, :only => [:id_sender, :cipher, :iv, :key_recipient_enc, :sig_recipient]
  end


  private
    def set_message
      @Message = Message.find(params[:id_recipient])
    end

    def outer_message_params
      params.require(:outerMessage).permit(:timestamp, :sig_service, :id_sender, :cipher, :iv, :key_recipient_enc, :sig_recipient)
    end
end