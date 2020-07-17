defmodule InterfaceWeb.ArchiveController do
  use InterfaceWeb, :controller

  def show(conn, params) do
    params =
      cond do
        Map.has_key?(params, "form_params") ->
          handle_form_params(Map.get(params, "form_params"))

        true ->
          default_params(params)
      end

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

  def handle_form_params(form_params) do
    form_params
    # |> IO.inspect()
    |> handle_tag_in_form_params()
    |> type_to_atom()
    |> date_to_string()
    |> string_keys_to_atoms()
    |> Enum.into(%{})
  end

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

  defp handle_tag_in_form_params(form_params) do
    # if the tag field is an empty string, remove the field
    # else, do nothing

    cond do
      Map.get(form_params, "tag") == "" ->
        Map.delete(form_params, "tag")

      true ->
        form_params
    end
  end

  defp type_to_atom(form_params) do
    cond do
      Map.get(form_params, "type") == ""  || Map.get(form_params, "type") == nil->
        Map.update!(form_params, "type", fn _type -> :news end)

      true ->
        Map.update!(form_params, "type", fn type -> String.to_atom(type) end)
    end
  end

  defp date_to_string(form_params) do
    form_params
    |> Map.update!("since", fn date_map -> handle_date_map(date_map) end)
    |> Map.update!("until", fn date_map -> handle_date_map(date_map) end)
  end

  defp handle_date_map(date_map) do
    day = Map.get(date_map, "day") |> expand_date_digit()
    month = Map.get(date_map, "month") |> expand_date_digit()
    year = Map.get(date_map, "year")
    "#{year}-#{month}-#{day}"
  end

  defp expand_date_digit(value) do
    cond do
      String.length(value) == 1 ->
        "0#{value}"

      true ->
        value
    end
  end
end
