defmodule Dog do
  use SafeMachine

  # Defines the struct %Dog{}
  @enforce_keys [:name]
  defstruct name: nil, state: :puppy
  @type t :: %Dog{name: String.t, state: Atom}

  transition :puppy, to: :dog do
    IO.puts("bark")
  end

  transition :dog, to: :wolf do
    IO.puts("Hmm, I'm still a dog.")
    throw [:not_a_wolf, "Too young"]
  catch
    [:not_a_wolf, reason] ->
      IO.puts "SAFE ERROR: not_a_wolf, #{reason}."
  after
    IO.puts("after woof")
  end

  safe_machine_finish()
end

defmodule SafeMachineTest do
  use ExUnit.Case
  doctest SafeMachine

  require Logger

  test "macro definition" do

    doge = %Dog{name: "JC"}
    Logger.info("Initial struct: " <> inspect(doge))
    Logger.info("Dog state transitions: " <> inspect(Dog.get_state_transitions))

    # IO.inspect(Dog.__info__(:functions))
    # IO.inspect(Dog.get_env)
    {:ok, doge} = Dog.do_transition(doge, :puppy, :dog)
    {:error, doge} = Dog.do_transition(doge, :dog, :wolf)

    # > not_doge = 1
    # > doge = Dog.do_transition(no_doge, :dog, :wolf)
    # => emits No Function Available error
    #
    # > doge = Dog.do_transition(doge, :dog, :wolf)
    # => emits No Function Available error becaus
    Logger.info("End Dog: " <> inspect(doge))
  end
end
