# frozen_string_literal: true

class AuthorizationController < ApplicationController
  def google
    authorization_url = WorkOS::SSO.authorization_url(
      provider: 'GoogleOAuth',
      project_id: ENV['WORKOS_CLIENT_ID'],
      redirect_uri: "#{ENV['SENDCHINATOWNLOVE_API_URL']}/auth/callback"
    )
    json_response({ authorization_url: authorization_url })
  end

  def passwordless
    session = WorkOS::Passwordless.create_session(
      type: 'MagicLink',
      email: params[:email]
    )

    EmailManager::MagicLinkSender.call(
      {
        email: params[:email],
        magic_link_url: session.link
      }
    )

    # Redirect to Check Email page in UI.
  end

  # auth/validate
  def validate
    hasSession = session[:user] != nil
    if (hasSession)
      json_response(nil)
    else
      json_response(nil, :unauthorized)
    end
  end

  def callback
    profile = WorkOS::SSO.profile(
      code: params['code'],
      project_id: ENV['WORKOS_CLIENT_ID']
    )

    session[:user] = profile.to_json

    redirect_to ENV['DISTRIBUTOR_DASHBOARD_URL'] || '/'
  end
end
