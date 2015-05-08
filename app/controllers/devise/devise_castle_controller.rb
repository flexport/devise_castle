class Devise::DeviseCastleController < DeviseController
  include Devise::Controllers::Helpers

  before_filter :return_not_found, except: :new

  before_filter do
    env['castle.skip_authorization'] = true
  end

  def new
    challenge = castle.challenges.create
    Devise.mappings.keys.flatten.any? do |scope|
      redirect_to send(
        "edit_#{scope}_two_factor_authentication_path", challenge.id)
    end
  end

  def edit
    @challenge = castle.challenges.find(params[:id])

    # Prevent "undefined method `errors' for nil:NilClass"
    self.resource = resource_class.new

    render action: "#{@challenge.delivery_method}/edit"
  end

  def update
    challenge_id = params.require(:challenge_id)
    code = params.require(:code)

    begin
      castle.challenges.verify(challenge_id, response: code)

      castle.trust_device if params[:trust_device]

      Devise.mappings.keys.flatten.any? do |scope|
        redirect_to after_sign_in_path_for(scope)
      end
    rescue Castle::Error
      sign_out_with_message(:no_retries_remaining, :alert)
    end
  end

  protected

  def sign_out_with_message(message, kind = :notice)
    signed_out = sign_out(resource_name)
    set_flash_message kind, message if signed_out
    redirect_to after_sign_out_path_for(resource_name)
  end

  private

  def return_not_found
    unless castle.mfa_in_progress?
      redirect_to after_sign_in_path_for(resource_name)
    end
  end

end