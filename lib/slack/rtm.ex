defmodule JSX.DecodeError do
  defexception [:reason, :string]

  def message(%JSX.DecodeError{reason: reason, string: string}) do
    "JSX could not decode string for reason: `:#{reason}`, string given:\n#{string}"
  end
end

defmodule Slack.Rtm do
  @moduledoc false

  def start(token) do
    IO.puts "-> Starting...The token is #{token}"

    slack_url(token)
    |> HTTPoison.get()
    |> handle_response()
  end

  defp handle_response({:ok, %HTTPoison.Response{body: body}}) do
    IO.puts "-> We are in the OK handler"

    case JSX.decode(body, [{:labels, :atom}]) do
      {:ok, %{ok: true} = json} -> {:ok, json}
      {:ok, %{error: reason}} -> {:error, "Slack API returned an error `#{reason}.\n Response: #{body}"}
      {:error, reason} -> {:error, %JSX.DecodeError{reason: reason, string: body}}
      _ -> {:error, "Invalid RTM response"}
    end
  end

  defp handle_response(error), do: error

  defp handle_close(reason, slack, state) do
    IO.puts "<---------------------------------->"
    IO.puts "-> The connection has been closed :("
    IO.inspect reason
    IO.inspect slack
    IO.inspect state
    IO.puts "<---------------------------------->"
  end

  defp slack_url(token) do
    Application.get_env(:slack, :url, "https://slack.com") <> "/api/rtm.start?token=#{token}"
  end
end
