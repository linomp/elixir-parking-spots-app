defmodule Fmps.Sales do
  @moduledoc """
  The Sales context.
  """

  import Ecto.Query, warn: false
  alias Fmps.Repo

  alias Fmps.Sales.Booking
  alias Ecto.{Multi, Changeset}

  @doc """
  Returns the list of bookings.

  ## Examples

      iex> list_bookings()
      [%Booking{}, ...]

  """
  def list_bookings do
    Repo.all(Booking)
  end

  @doc """
  Gets a single booking.

  Raises `Ecto.NoResultsError` if the Booking does not exist.

  ## Examples

      iex> get_booking!(123)
      %Booking{}

      iex> get_booking!(456)
      ** (Ecto.NoResultsError)

  """
  def get_booking!(id), do: Repo.get!(Booking, id)

  @doc """
  Creates a booking.

  ## Examples

      iex> create_booking(%{field: value})
      {:ok, %Booking{}}

      iex> create_booking(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_booking(attrs \\ %{}) do

    changeset = %Booking{} |> Booking.changeset(attrs["bookingParams"])

    case Ecto.Changeset.apply_action(changeset, :update) do
      {:ok, _} ->
        {_, data} = Multi.new
        |> Multi.insert(:booking, changeset
          |> Changeset.put_change(:user_id, attrs["user"].id)
          |> Changeset.put_change(:parking_spot_id, attrs["parkingSpot"].id)
          |> Changeset.put_change(:is_paid, attrs["is_paid"])
          |> Changeset.put_change(:price, attrs["price"])
        )
        |> Repo.transaction

        if data.booking.is_hourly do
          # start an async job to update booking status & parking lot availability at a future time
          GenServer.start(Fmps.BookingExpiryTask, data.booking.id)
        end

        {:ok, data.booking}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}

    end

  end

  @doc """
  Updates a booking.

  ## Examples

      iex> update_booking(booking, %{field: new_value})
      {:ok, %Booking{}}

      iex> update_booking(booking, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_booking(%Booking{} = booking, attrs) do
    booking
    |> Booking.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a booking.

  ## Examples

      iex> delete_booking(booking)
      {:ok, %Booking{}}

      iex> delete_booking(booking)
      {:error, %Ecto.Changeset{}}

  """
  def delete_booking(%Booking{} = booking) do
    Repo.delete(booking)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking booking changes.

  ## Examples

      iex> change_booking(booking)
      %Ecto.Changeset{data: %Booking{}}

  """
  def change_booking(%Booking{} = booking, attrs \\ %{}) do
    Booking.changeset(booking, attrs)
  end
end
