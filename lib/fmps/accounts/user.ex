defmodule Fmps.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :licence_number, :string
    field :name, :string
    field :password, :string, virtual: true
    field :hashed_password, :string
    field :balance, :float, default: 0.0
    field :is_monthly_payment, :boolean, default: false

    has_many :bookings, Fmps.Sales.Booking

    timestamps()
    end

    def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :licence_number, :email, :password, :balance, :is_monthly_payment])
    |> validate_required([:name, :licence_number, :email, :password])
    |> unique_constraint(:email)
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 6)
    |> hash_password
    end

    defp hash_password(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, hashed_password: Pbkdf2.hash_pwd_salt(password))
    end
    defp hash_password(changeset), do: changeset

    end
