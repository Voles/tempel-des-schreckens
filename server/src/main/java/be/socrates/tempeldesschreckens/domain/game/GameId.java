package be.socrates.tempeldesschreckens.domain.game;

import java.util.Objects;
import java.util.UUID;

public class GameId {
    private UUID value;

    private GameId(final UUID value) {
        this.value = value;
    }

    public static GameId gameId() {
        return new GameId(UUID.randomUUID());
    }

    public UUID getValue() {
        return value;
    }

    @Override
    public boolean equals(final Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        final GameId gameId = (GameId) o;
        return Objects.equals(value, gameId.value);
    }

    @Override
    public int hashCode() {
        return Objects.hash(value);
    }

    @Override
    public String toString() {
        return "GameId{" +
                "value=" + value +
                '}';
    }
}
