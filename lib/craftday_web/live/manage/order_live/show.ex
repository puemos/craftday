defmodule CraftdayWeb.OrderLive.Show do
  @moduledoc false
  use CraftdayWeb, :live_view

  alias Craftday.Catalog
  alias Craftday.Catalog.Product.Photo
  alias Craftday.CRM
  alias Craftday.Orders

  @default_order_load [
    :total_cost,
    items: [:cost, :product],
    customer: [:full_name, shipping_address: [:full_address]]
  ]

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      <.breadcrumb>
        <:crumb label="All Orders" path={~p"/manage/orders"} current?={false} />
        <:crumb
          label={format_reference(@order.reference)}
          path={~p"/manage/orders/#{@order.reference}"}
          current?={true}
        />
      </.breadcrumb>

      <:actions>
        <.link patch={~p"/manage/orders/#{@order.reference}/edit"} phx-click={JS.push_focus()}>
          <.button>Edit order</.button>
        </.link>
      </:actions>
    </.header>

    <div class="mt-4">
      <.tabs id="order-tabs">
        <:tab
          label="Details"
          path={~p"/manage/orders/#{@order.reference}/details"}
          selected?={@live_action == :details || @live_action == :show}
        >
          <.list>
            <:item title="Reference">
              <.kbd>
                {format_reference(@order.reference)}
              </.kbd>
            </:item>

            <:item title="Status">
              <.badge
                text={@order.status}
                colors={[
                  {@order.status,
                   "#{order_status_color(@order.status)} #{order_status_bg(@order.status)}"}
                ]}
              />
            </:item>

            <:item title="Customer">
              <.link
                class="hover:text-blue-800 hover:underline"
                navigate={~p"/manage/customers/#{@order.customer.reference}"}
              >
                {@order.customer.full_name}
              </.link>
            </:item>
            <:item title="Shipping Address">{@order.customer.shipping_address.full_address}</:item>

            <:item title="Total">
              {format_money(@settings.currency, @order.total_cost)}
            </:item>

            <:item title="Delivery Date">
              {format_time(@order.delivery_date, @time_zone)}
            </:item>

            <:item title="Created At">
              {format_time(@order.inserted_at, @time_zone)}
            </:item>
          </.list>
        </:tab>

        <:tab
          label="Items"
          path={~p"/manage/orders/#{@order.reference}/items"}
          selected?={@live_action == :items}
        >
          <.table id="order-items" rows={@order.items}>
            <:col :let={item} label="Product">
              <.link
                class="hover:text-blue-800 hover:underline"
                navigate={~p"/manage/products/#{item.product.sku}"}
              >
                <div class="flex items-center space-x-2">
                  <img
                    :if={item.product.featured_photo != nil}
                    src={Photo.url({item.product.featured_photo, item.product}, :thumb, signed: true)}
                    alt={item.product.name}
                    class="h-5 w-5"
                  />
                  <span>
                    {item.product.name}
                  </span>
                </div>
              </.link>
            </:col>
            <:col :let={item} label="Quantity">{item.quantity}</:col>
            <:col :let={item} label="Unit Price">
              {format_money(@settings.currency, item.product.price)}
            </:col>
            <:col :let={item} label="Total">
              {format_money(@settings.currency, item.cost)}
            </:col>
          </.table>
        </:tab>
      </.tabs>
    </div>

    <.modal
      :if={@live_action == :edit}
      id="order-modal"
      show
      title={@page_title}
      on_cancel={JS.patch(~p"/manage/orders/#{@order.reference}")}
    >
      <.live_component
        module={CraftdayWeb.OrderLive.FormComponent}
        id={(@order && @order.id) || :new}
        current_user={@current_user}
        title={@page_title}
        action={@live_action}
        order={@order}
        products={@products}
        customers={@customers}
        settings={@settings}
        patch={~p"/manage/orders/#{@order.reference}"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    products =
      Catalog.list_products!(actor: socket.assigns[:current_user])

    customers =
      CRM.list_customers!(actor: socket.assigns[:current_user], load: [:full_name])

    {:ok,
     assign(socket,
       products: products,
       customers: customers
     )}
  end

  @impl true
  def handle_params(%{"reference" => reference}, _, socket) do
    order =
      Orders.get_order_by_reference!(reference, load: @default_order_load)

    socket =
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:order, order)

    {:noreply, socket}
  end

  @impl true
  def handle_info({CraftdayWeb.OrderLive.FormComponentItems, {:saved, _}}, socket) do
    order =
      Orders.get_order_by_id!(socket.assigns.order.id, load: @default_order_load)

    {:noreply,
     socket
     |> put_flash(:info, "Order items updated successfully")
     |> assign(:order, order)
     |> push_event("close-modal", %{id: "order-item-modal"})}
  end

  @impl true
  def handle_info({CraftdayWeb.OrderLive.FormComponent, {:saved, _}}, socket) do
    order =
      Orders.get_order_by_id!(socket.assigns.order.id, load: @default_order_load)

    {:noreply,
     socket
     |> put_flash(:info, "Order updated successfully")
     |> assign(:order, order)}
  end

  defp page_title(:show), do: "Show Order"
  defp page_title(:edit), do: "Edit Order"
  defp page_title(:details), do: "Order Details"
  defp page_title(:items), do: "Order Items"
end
