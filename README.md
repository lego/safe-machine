# SafeMachine

Create simple and safe state machine models.


```elixir
#
# Define your struct, with a default state of :puppy
defmodule Animal do
  defstruct name: nil, state: :puppy, age: 1
end

# Include the SafeMachine DSL
use SafeMachine

#
# Create your first transition
defmodule Animal do
  deftransition(%Animal{state: :puppy} = animal, to: :dog) do
    %{dog | name: "Alfred"}
  end
end


# Run a state machine transition on the struct
{:ok, result} = Animal.do_transition(%Animal{}, :puppy, :dog)
IO.inspect(result)
# > %Animal{state: :dog, name: "Alfred"}


#
# What about if we throw during a transition? (note the use of pattern matching)
defmodule Animal do
  deftransition(%Animal{state: :puppy, age: 0} = animal, to: :dog) do
    throw :this_puppy_isnt_old_enough
  end
end

{:error, result} = Animal.do_transition(%Animal{age: 0}, :puppy, :dog)
IO.inspect(result)
# > :this_puppy_isnt_old_enough


#
# It's possible to use complete struct pattern matching and guards
defmodule Animal do
  deftransition(%Animal{state: :puppy, age: age} = animal, to: :dog) when age > 2 do
    %{animal | age: age * 2}
  end
end

{:error, result} = Animal.do_transition(%Animal{age: 0}, :puppy, :dog)
IO.inspect(result)
# > :this_puppy_isnt_old_enough


#
# We can create a linear transition
defmodule Animal do
  deftransition(%Animal{state: :dog} = animal, to: :wolf)
end

{:ok, result} = Animal.fully_transition(%Animal{})
IO.inspect(result)
# > %Animal{state: :wolf, name: "Alfred"}


# Which can safely fail part-way
{:error, result} = Animal.fully_transition(%Animal{age: 0})
IO.inspect(result)
# > :this_puppy_isnt_old_enough


#
# We can check out all possible
IO.inspect(Animal.get_state_transitions())
# > %{puppy: :dog, dog: :wolf}
```

## Missing features

- `when` guard support on transitions
- top-level `catch`, `else`, `rescue`, and `after` block support
- static analysis for linear states (or an option to allow circular states)
- add `fully_transition` behaviour
- `get_state_transitions` with better expansion of matching conditions, as opposed to only state `from -> to` transitions





## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `safe_machine` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:safe_machine, "~> 0.1.0"}]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/safe_machine](https://hexdocs.pm/safe_machine).
