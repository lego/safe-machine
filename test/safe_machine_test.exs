defmodule Animal do
  use SafeMachine

  @enforce_keys [:name]
  defstruct name: nil, state: :puppy, level: 1
  @type t :: %Animal{name: String.t, state: Atom, level: Integer.t}

  deftransition(%Animal{state: :puppy, name: "Modify", level: level} = dog, to: :dog) do
    %{dog | level: level + 1}
  end

  deftransition(%Animal{state: :puppy, name: "Bad"} = dog, to: :dog) do
    %{dog | state: :evil}
  end

  deftransition(%Animal{state: :puppy, name: "Conditional", level: level} = dog, to: :dog) do
    if level == 1 do
      throw [:something_happened]
    else
      %{dog | level: level + 1}
    end
  end

  deftransition(%Animal{state: :puppy, name: "Bad Premature"} = dog, to: :dog) do
    %{dog | state: :dog}
  end

  deftransition(%Animal{state: :puppy, name: "Empty block"} = dog, to: :dog)

  # FIXME: how do we safely do side effects?
  deftransition(%Animal{state: :puppy, name: "Side effects"} = dog, to: :dog) do
    unsafe do
      IO.puts("Side effects")
    end
  end

  deftransition(%Animal{state: :puppy} = dog, to: :dog)

  # FIXME: not yet handled, use of special catch conditions
  deftransition(%Animal{state: :dog, name: "Handled throw"} = dog, to: :wolf) do
    throw [:not_a_wolf, "Too young"]
  catch
    [:not_a_wolf, reason] ->
      IO.puts "SAFE ERROR: not_a_wolf, #{reason}."
  end

  deftransition(%Animal{state: :dog, name: "Unhandled throw"} = dog, to: :wolf) do
    throw [:not_a_wolf, "Too young"]
  end

  safe_machine_finish()
end

defmodule SafeMachineTest do
  use ExUnit.Case
  doctest SafeMachine

  require Logger

  test "state transitions" do
    assert %{dog: :wolf, puppy: :dog} == Animal.get_state_transitions
  end

  test "transition modifies contents" do
    doge = %Animal{name: "Modify", level: 2}
    assert {:ok, %Animal{name: "Modify", level: 3, state: :dog}} == Animal.do_transition(doge, :puppy, :dog)
  end

  test "failure when transition mutates state" do
    doge = %Animal{name: "Bad"}
    assert_raise RuntimeError, ~r/Did not expect/, fn ->
      Animal.do_transition(doge, :puppy, :dog)
    end
  end

  test "failure when transition mutates state to destination state" do
    doge = %Animal{name: "Bad Premature"}
    assert_raise RuntimeError, ~r/Did not expect/, fn ->
      Animal.do_transition(doge, :puppy, :dog)
    end
  end

  test "transition changing behaviour" do
    doge = %Animal{name: "Conditional", level: 2}
    assert {:ok, %Animal{name: "Conditional", level: 3, state: :dog}} == Animal.do_transition(doge, :puppy, :dog)

    doge = %Animal{name: "Conditional", level: 1}
    assert {:error, [:something_happened]} == Animal.do_transition(doge, :puppy, :dog)
  end

  test "transition with empty block" do
    doge = %Animal{name: "Empty block"}
    assert {:ok, %Animal{name: "Empty block", state: :dog}} == Animal.do_transition(doge, :puppy, :dog)
  end

  test "transition with side effects" do
    doge = %Animal{name: "Empty block"}
    assert {:ok, %Animal{name: "Empty block", state: :dog}} == Animal.do_transition(doge, :puppy, :dog)
  end

  #   # Logger.info("Initial struct: " <> inspect(doge))
  #   # Logger.info("Animal state transitions: " <> inspect(Animal.get_state_transitions))
  #
  #   # IO.inspect(Animal.__info__(:functions))
  #   # IO.inspect(Animal.get_env)
  #   {:ok, doge} = Animal.do_transition(doge, :puppy, :dog)
  #   {:error, doge} = Animal.do_transition(doge, :dog, :wolf)
  #
  #   # > not_doge = 1
  #   # > doge = Animal.do_transition(no_doge, :dog, :wolf)
  #   # => emits No Function Available error
  #   #
  #   # > doge = Animal.do_transition(doge, :dog, :wolf)
  #   # => emits No Function Available error becaus
  #   Logger.info("End Animal: " <> inspect(doge))
  # end
end
