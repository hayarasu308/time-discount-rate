defmodule TimeRate do
  use Xee.ThemeScript
  require Logger

  require_file "scripts/main.exs"
  require_file "scripts/host.exs"
  require_file "scripts/participant.exs"
  require_file "scripts/actions.exs"

  alias TimeRate.Main
  alias TimeRate.Host
  alias TimeRate.Participant

  # Callbacks
  def script_type do
    :message
  end

  def install, do: nil

  def init do
    {:ok, %{"data" => Main.init()}}
  end

  def wrap_result({:ok, _} = result), do: result
  def wrap_result(result), do: Main.wrap(result)

  def join(data, id) do
    wrap_result(Main.join(data, id))
  end

  # Host router
  def handle_received(data, %{"action" => action, "params" => params}) do
    Logger.debug("[Time Rate] #{action} #{params}")
    result = case {action, params} do
      {"fetch contents", _} -> Host.fetch_contents(data)
      {"change page", page} -> Host.change_page(data, page)
      {"all reset", _}      -> Host.all_reset(data)
      _ -> {:ok, %{"data" => data}}
    end
    wrap_result(result)
  end

  # Participant router
  def handle_received(data, %{"action" => action, "params" => params}, id) do
    Logger.debug("[Time Rate] #{action}")
    result = case {action, params} do
      {"fetch contents", _} -> Participant.fetch_contents(data, id)
      {"set question", question} -> Participant.set_question(data,id,question)
      {"next", rate} -> Participant.next(data,id,rate)
      {"finish", _} -> Participant.finish(data,id)
      _ -> {:ok, %{"data" => data}}
    end
    wrap_result(result)
  end
end
