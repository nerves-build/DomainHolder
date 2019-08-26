defmodule DomainHolder.Domains.Domain do

  alias DomainHolder.Domains.Domain

  import Ecto.Changeset
  use Ecto.Schema
  
  embedded_schema do
    field :host
    field :name
    field :tagline
    field :description
    field :color
    field :count, :integer, default: 0
  end

  @allowed_fields [:id, :host, :name, :tagline, :description, :color]
  
  def changeset(%Domain{} = domain \\ %Domain{}, %{} = params \\ %{}) do
    domain
    |> Ecto.Changeset.cast(params, @allowed_fields)
    |> validate_required([:host])
    |> generate_id_if_empty
  end

  defp generate_id_if_empty(changeset) do
    case get_field(changeset, :id) do
      nil -> 
        put_change(changeset, :id, UUID.uuid4())
        _ -> changeset
    end
  end

end
