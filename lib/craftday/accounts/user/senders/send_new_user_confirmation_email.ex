defmodule Craftday.Accounts.User.Senders.SendNewUserConfirmationEmail do
  @moduledoc """
  Sends an email for a new user to confirm their email address.
  """

  use AshAuthentication.Sender
  use CraftdayWeb, :verified_routes

  @impl true
  def send(user, token, _) do
    Craftday.Accounts.Emails.deliver_new_user_confirmation_email(
      user,
      url(~p"/auth/user/confirm_new_user?#{[confirm: token]}")
    )
  end
end
