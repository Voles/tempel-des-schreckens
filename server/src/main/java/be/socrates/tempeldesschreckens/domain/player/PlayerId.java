package be.socrates.tempeldesschreckens.domain.player;

import java.util.Objects;

public class PlayerId {
    private int value;

    private PlayerId(final int value) {
        this.value = value;
    }

    public static PlayerId playerId(int playerNumber) {
        return new PlayerId(playerNumber);
    }

    public int getValue() {
        return value;
    }

    @Override
    public boolean equals(final Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        final PlayerId playerId = (PlayerId) o;
        return Objects.equals(value, playerId.value);
    }

    @Override
    public int hashCode() {
        return Objects.hash(value);
    }

    @Override
    public String toString() {
        return "PlayerId{" +
                "value=" + value +
                '}';
    }
}
