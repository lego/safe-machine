defmodule SafeMachine do

  @doc false
  defmacro __using__(_opts) do
    quote do
      require Logger
      import SafeMachine
      Module.register_attribute(__MODULE__, :state_transitions, accumulate: true)
    end
  end

  defmacro safe_machine_finish do
    quote do
      def get_state_transitions do
        @state_transitions
      end
      def get_env do
        __ENV__
      end
    end
  end

  @doc false
  defmacro transition(from, to: to) do
    quote do
      Module.put_attribute(__MODULE__, :state_transitions, [unquote(from), unquote(to)])
    end
  end

  defmacro transition(from, [to: to], clause) do
    # IO.inspect(Enum.map(Keyword.get_values(clause, :rescue), fn v -> {:rescue, v} end))
    # IO.inspect(Code.compile_string("rescue e in RunetimeError -> e"))
    # IO.inspect(clause[:catch])
    quote do
      Module.put_attribute(__MODULE__, :state_transitions, [unquote(from), unquote(to)])
      def do_transition(%__MODULE__{state: unquote(from)} = self, unquote(from) = from, unquote(to) = to) do
        Logger.debug("TRANSITION MACRO: do_transition " <> Atom.to_string(from) <> " ~> " <> Atom.to_string(to))
        Logger.debug("SELF:  " <> inspect(self))
        result = try do
          unquote(clause[:do])
          Logger.debug("DO FINISHED")
          %{self | state: to}
        catch
          unquote(clause[:catch] || [])
        after
          unquote(clause[:after])
          Logger.debug("AFTER FINISHED")
        end
        Logger.debug("TRANSITION MACRO: end " <> Atom.to_string(from) <> " ~> " <> Atom.to_string(to))
        case result do
          %__MODULE__{state: to} = self -> {:ok, self}
          _ -> {:error, result}
        end
      end
    end
  end
end
