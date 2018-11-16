package be.socrates.tempeldesschreckens.domain.player;

import be.socrates.tempeldesschreckens.domain.Room;

import java.util.List;
import java.util.Objects;

public class Player {
    private PlayerId playerId;
    private Role role;
    private List<Room> rooms;

    public Player(final PlayerId playerId, final Role role, final List<Room> rooms) {
        this.playerId = playerId;
        this.role = role;
        this.rooms = rooms;
    }

    public PlayerId getPlayerId() {
        return playerId;
    }

    public Role getRole() {
        return role;
    }

    public List<Room> getCards() {
        return rooms;
    }

    public static class PlayerBuilder {
        private PlayerId playerId;
        private Role role;
        private List<Room> rooms;

        private PlayerBuilder() {
        }

        public static PlayerBuilder player() {
            return new PlayerBuilder();
        }

        public PlayerBuilder withPlayerId(final PlayerId playerId) {
            this.playerId = playerId;
            return this;
        }

        public PlayerBuilder withRole(final Role role) {
            this.role = role;
            return this;
        }

        public PlayerBuilder withCards(final List<Room> rooms) {
            this.rooms = rooms;
            return this;
        }

        public Player build() {
            return new Player(playerId, role, rooms);
        }
    }

    @Override
    public boolean equals(final Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        final Player player = (Player) o;
        return Objects.equals(playerId, player.playerId) &&
                role == player.role &&
                Objects.equals(rooms, player.rooms);
    }

    @Override
    public int hashCode() {
        return Objects.hash(playerId, role, rooms);
    }
}
