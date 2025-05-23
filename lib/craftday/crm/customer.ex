defmodule Craftday.CRM.Customer do
  @moduledoc false
  use Ash.Resource,
    otp_app: :craftday,
    domain: Craftday.CRM,
    data_layer: AshPostgres.DataLayer

  alias Craftday.CRM.Address

  require Ash.Resource.Preparation.Builtins

  postgres do
    table "crm_customers"
    repo Craftday.Repo
  end

  actions do
    default_accept :*
    defaults [:read, :create, :update, :destroy]

    read :list do
      prepare build(sort: :first_name)

      pagination do
        required? false
        offset? true
        keyset? true
        countable true
      end
    end

    read :keyset do
      prepare build(sort: :first_name)
      pagination keyset?: true
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :reference, :string do
      writable? false

      default fn ->
        random_str =
          12
          |> :crypto.strong_rand_bytes()
          |> Base.encode32(padding: false, case: :upper)
          |> String.slice(0..11)

        "CUS_#{random_str}"
      end

      allow_nil? false
      generated? true

      constraints match: ~r/^CUS_[A-Z0-9]{12}$/,
                  allow_empty?: false
    end

    attribute :type, :atom do
      allow_nil? false
      public? true
      constraints one_of: [:individual, :company]
    end

    attribute :first_name, :string do
      allow_nil? false
      public? true
      constraints min_length: 1
    end

    attribute :last_name, :string do
      allow_nil? false
      public? true
      constraints min_length: 1
    end

    attribute :email, :string do
      allow_nil? true
      public? true
      constraints match: ~r/@/
    end

    attribute :phone, :string do
      allow_nil? true
      public? true
      constraints max_length: 15
    end

    attribute :billing_address, Address do
      public? true
    end

    attribute :shipping_address, Address do
      public? true
    end

    timestamps()
  end

  relationships do
    has_many :orders, Craftday.Orders.Order
  end

  calculations do
    calculate :full_name, :string, expr(first_name <> " " <> last_name)
  end

  aggregates do
    count :total_orders, :orders

    sum :total_orders_value, [:orders, :items], :cost do
    end
  end

  identities do
    identity :phone, [:phone]
    identity :email, [:email]
    identity :reference, [:reference]
  end
end
