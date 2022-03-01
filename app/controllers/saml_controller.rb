class SamlController < ApplicationController
  skip_before_action :login_required
  skip_before_action :verify_authenticity_token

  def init
    request = OneLogin::RubySaml::Authrequest.new
    redirect_to(request.create(saml_settings))
  end

  def consume
    response = OneLogin::RubySaml::Response.new(params[:SAMLResponse])
    request = OneLogin::RubySaml::Authrequest.new
    response.settings = saml_settings

    # We validate the SAML Response and check if the user already exists in the system
    if response.is_valid?
       # authorize_success, log the user
      session[:saml_email] = response.nameid
      redirect_to :root
    else
      redirect_to(request.create(saml_settings))
    end
  end

  private

  def saml_settings
    idp_metadata_parser = OneLogin::RubySaml::IdpMetadataParser.new
    settings = idp_metadata_parser.parse(idp_metadata)
    settings.assertion_consumer_service_url = "http://localhost:3000/saml/consume"
    settings.issuer = 'prediction-app'
    settings.name_identifier_format = "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"
    settings

    settings
  end

  def idp_metadata
    ENV['IDP_METADATA']
  end
end
