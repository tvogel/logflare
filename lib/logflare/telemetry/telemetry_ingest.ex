defmodule Logflare.TelemetryBackend.BQ do
  @moduledoc false
  require Logger
  alias Logflare.Logs
  alias Logflare.Sources
  @default_source_id Application.get_env(:logflare_telemetry, :source_id)
  alias Telemetry.Metrics.{Counter, Distribution, LastValue, Sum, Summary}
  alias LogflareTelemetry, as: LT
  alias LT.ExtendedMetrics, as: ExtMetrics

  def ingest(payload) do
    source = Sources.Cache.get_by_id(@default_source_id)

    payload = prepare_for_bq(payload)
    Logs.ingest_logs(payload, source)

    :ok
  end

  def prepare_for_bq(payload) when is_map(payload) do
    for {k, v} <- payload, into: %{} do
      k =
        k
        |> String.replace("logflare.", "")
        |> String.replace(".", "__")

      {k, prepare_for_bq(v)}
    end
  end

  def prepare_for_bq(payload) when is_list(payload) do
    for v <- payload, do: prepare_for_bq(v)
  end

  def prepare_for_bq(payload), do: payload
end
