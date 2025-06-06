defmodule Craftday.Settings do
  @moduledoc false
  use Ash.Domain

  resources do
    resource Craftday.Settings.Settings do
      define :init, action: :init
      define :set, action: :update
      define :get, action: :get
      define :get_by_id, action: :read, get_by: [:id]
    end
  end
end
