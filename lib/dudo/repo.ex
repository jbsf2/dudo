defmodule Dudo.Repo do
  use Ecto.Repo,
    otp_app: :dudo,
    adapter: Ecto.Adapters.Postgres
end
