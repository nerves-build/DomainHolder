defmodule DomainHolder.Domains.State do
  defstruct domains: %{}

  use GenServer

  require Logger

  alias DomainHolder.Domains.Domain
  alias DomainHolder.Domains.State
  alias DomainHolder.Domains

  @file_location Application.get_env(:domain_holder, :prefs_location) |> Path.expand()

  @moduledoc false

  def start_link(_args) do
    GenServer.start_link(__MODULE__, %State{}, name: State)
  end

  def get_domains do
    GenServer.call(State, :get_domains)
  end

  def increment_counter(domain) do
    GenServer.call(State, {:increment_counter, domain})
  end

  def add_domain(params) do
    Domains.change_domain(%Domain{}, params)
    |> case do
      %{valid?: true} = changeset ->
        GenServer.call(State, {:add_domain, changeset})
      changeset ->
        {:error, changeset}
    end
  end

  def update_domain(domain, params) do
    Domains.change_domain(domain, params)
    |> case do
      %{valid?: true} = changeset ->
        GenServer.call(State, {:update_domain, changeset})
      changeset ->
        {:error, changeset}
    end
  end

  def delete_domain(domain) do
    GenServer.call(State, {:delete_domain, domain})
  end

  def get_state do
    GenServer.call(State, :get_state)
  end

  def set_state(new_state) do
    GenServer.call(State, {:set_state, new_state})
  end

  def init(data) do
    Process.send_after(self(), :post_init, 100)
    {:ok, data}
  end

  def handle_info(:post_init, state = %State{}) do
    new_state = if File.exists?(@file_location) do     
      old_state = File.read!(@file_location) |> :erlang.binary_to_term()

      Enum.reduce(old_state.domains, state, fn({_id, d}, state) ->
        changeset = Domains.change_domain(d, %{})
        {_dmn, state} = handle_add(changeset, state)
        state
      end)
    else
      File.open!(@file_location, [:read, :write])
      File.write!(@file_location, :erlang.term_to_binary(state))
      state
    end

    {:noreply, new_state}
  end

  def handle_call(:get_domains, _from, state = %State{domains: domains}) do
    {:reply, domains, state}
  end

  def handle_call({:add_domain, domain}, _from, state) do
    {new_domain, new_state} = handle_add(domain, state)

    {:reply, {:ok, new_domain}, new_state}
  end

  def handle_call({:update_domain, changeset}, _from, state) do
    new_domain = Ecto.Changeset.apply_changes(changeset)
    new_state = put_domain_into_state(new_domain, state)

    {:reply, {:ok, new_domain}, new_state}
  end

  def handle_call({:delete_domain, domain = %{id: id}}, _from, state = %State{domains: domains}) do
    new_data = 
      state
      |> struct(domains: Map.delete(domains, id))
      |> flush()

    {:reply, {:ok, domain}, new_data}
  end

  def handle_call({:increment_counter, _domain = %{id: id}}, _from, data = %State{domains: domains}) do
    with dmn <- Map.get(domains, id),
         {_, new_dm} <- Map.get_and_update(dmn, :count, fn val -> {val, val + 1} end),
         new_dmns <- Map.put(domains, id, new_dm),
         new_data <- struct(data, domains: new_dmns) do
      {:reply, {:ok, new_dm}, new_data}
    end
  end

  def handle_call(:get_state, _from, data) do
    {:reply, data, data}
  end

  def handle_call({:set_state, new_state}, _from, _data) do
    {:reply, new_state, new_state}
  end

  defp handle_add(changeset, state) do
    new_domain = Ecto.Changeset.apply_changes(changeset)
    new_data = put_domain_into_state(new_domain, state)
    
    {new_domain, new_data}
  end

  defp put_domain_into_state(domain, state = %State{domains: domains}) do
    domains = Map.put(domains, domain.id, domain)
    
    state
    |> struct(domains: domains)
    |> flush()
  end

  defp flush(state) do
    File.write!(@file_location, :erlang.term_to_binary(state))
    state
  end
end
