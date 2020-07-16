defmodule InterfaceWeb.ArchiveController do
  use InterfaceWeb, :controller

  def show(conn, params) do
    params = default_params(params)
    IO.inspect(params)

    type = Map.get(params, :type) |> handle_type()
    order_by = Map.get(params, :order_by)
    since = Map.get(params, :since)
    until = Map.get(params, :until)

    result =
      cond do
        Map.has_key?(params, :tag) ->
          ProtestArchive.DatabaseWorker.get_tag_between(
            type,
            Map.get(params, :tag),
            order_by,
            since,
            until
          )

        true ->
          ProtestArchive.DatabaseWorker.get_between(type, order_by, since, until)
      end

    render(conn, "show.html", data: result)
  end

  ##############################

  defp default_params(params) do
    params = string_keys_to_atoms(params)
    until = DateTime.utc_now() |> DateTime.to_string() |> String.slice(0, 10)

    default = [
      type: :news,
      order_by: "published_at",
      since: "2020-06-01",
      until: until
    ]

    Keyword.merge(default, params) |> Enum.into(%{})
  end

  defp string_keys_to_atoms(params) do
    Enum.map(params, fn {key, value} -> {String.to_atom(key), value} end)
  end

  defp handle_type(type) when is_atom(type), do: type

  defp handle_type(type) when is_bitstring(type), do: String.to_atom(type)
end
