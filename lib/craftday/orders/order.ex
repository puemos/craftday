defmodule Craftday.Orders.Order do
  @moduledoc false
  use Ash.Resource,
    otp_app: :craftday,
    domain: Craftday.Orders,
    data_layer: AshPostgres.DataLayer

  alias Craftday.Orders.Order.Types.PaymentStatus
  alias Craftday.Orders.Order.Types.Status

  postgres do
    table "orders_orders"
    repo Craftday.Repo
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      primary? true
      accept [:status, :customer_id, :delivery_date]

      argument :items, {:array, :map}

      change manage_relationship(:items, type: :direct_control)
    end

    update :update do
      require_atomic? false
      accept [:status, :customer_id, :delivery_date]

      argument :items, {:array, :map}

      change manage_relationship(:items, type: :direct_control)
    end

    read :list do
      prepare build(sort: [delivery_date: :asc], load: [:customer, items: [:product]])

      argument :status, {:array, :atom} do
        allow_nil? true
        default nil

        constraints items: [
                      one_of: Status.values()
                    ]
      end

      argument :payment_status, {:array, :atom} do
        allow_nil? true
        default nil

        constraints items: [
                      one_of: PaymentStatus.values()
                    ]
      end

      argument :delivery_date_start, :utc_datetime do
        allow_nil? true
        default nil
      end

      argument :delivery_date_end, :utc_datetime do
        allow_nil? true
        default nil
      end

      argument :customer_name, :string do
        allow_nil? true
        default nil
      end

      argument :product_id, :uuid do
        allow_nil? true
        default nil
      end

      filter expr(is_nil(^arg(:status)) or status in ^arg(:status))
      filter expr(is_nil(^arg(:payment_status)) or payment_status in ^arg(:payment_status))

      filter expr(is_nil(^arg(:delivery_date_start)) or delivery_date >= ^arg(:delivery_date_start))

      filter expr(is_nil(^arg(:delivery_date_end)) or delivery_date <= ^arg(:delivery_date_end))

      filter expr(
               is_nil(^arg(:customer_name)) or
                 fragment("? ILIKE ?", customer.full_name, "%" <> ^arg(:customer_name) <> "%")
             )

      filter expr(is_nil(^arg(:product_id)) or exists(items, product_id == ^arg(:product_id)))

      pagination do
        required? false
        offset? true
        keyset? true
        countable true
      end
    end

    read :keyset do
      prepare build(sort: [delivery_date: :asc])
      pagination keyset?: true
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :reference, :string do
      writable? false

      default fn ->
        year = DateTime.utc_now().year |> Integer.to_string() |> String.pad_leading(4, "0")
        month = DateTime.utc_now().month |> Integer.to_string() |> String.pad_leading(2, "0")
        day = DateTime.utc_now().day |> Integer.to_string() |> String.pad_leading(2, "0")
        random = for _ <- 1..6, into: "", do: <<Enum.random(?A..?Z)>>
        "OR_#{year}_#{month}_#{day}_#{random}"
      end

      allow_nil? false
      generated? true

      constraints match: ~r/^OR_\d{4}_\d{2}_\d{2}_[A-Z]{6}$/,
                  allow_empty?: false
    end

    attribute :delivery_date, :utc_datetime do
      allow_nil? false
    end

    attribute :status, Status do
      allow_nil? false
      default :unconfirmed
    end

    attribute :payment_status, PaymentStatus do
      allow_nil? false
      default :pending
    end

    timestamps()
  end

  relationships do
    has_many :items, Craftday.Orders.OrderItem

    belongs_to :customer, Craftday.CRM.Customer do
      allow_nil? false
      domain Craftday.CRM
    end
  end

  aggregates do
    count :total_items, :items
    sum :total_cost, :items, :cost
  end

  identities do
    identity :reference, [:reference]
  end
end
