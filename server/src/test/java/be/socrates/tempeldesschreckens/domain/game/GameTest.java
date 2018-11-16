package be.socrates.tempeldesschreckens.domain.game;

import be.socrates.tempeldesschreckens.domain.Room;
import be.socrates.tempeldesschreckens.domain.player.Role;
import org.junit.Test;

import java.util.Collections;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

public class GameTest {

    @Test
    public void newGame_With3Players_ShouldHave8EmptyRooms_And5Treasures_And2Traps() {
        Game game = Game.newGame(3);

        assertThat(game.rooms()).filteredOn(r -> r.equals(Room.EMPTY)).hasSize(8);
        assertThat(game.rooms()).filteredOn(r -> r.equals(Room.TREASURE)).hasSize(5);
        assertThat(game.rooms()).filteredOn(r -> r.equals(Room.TRAP)).hasSize(2);
    }

    @Test
    public void newGame_WithMoreThan10PlayerCount_ThrowsException() {
        assertThatThrownBy(() -> Game.newGame(11))
                .isInstanceOf(IllegalArgumentException.class);
    }

    @Test
    public void newGames_With3Players_ShouldHaveMaxTwoAdventurerRoles_AndMaxTwoGuardianRoles() {
        Game game = Game.newGame(3);

        assertThat(game.getRoles()).filteredOn(r -> r.equals(Role.ADVENTURER)).hasSize(2);
        assertThat(game.getRoles()).filteredOn(r -> r.equals(Role.GUARDIAN)).hasSize(2);
    }

    @Test
    public void newGame_With3Players_Initializes3Players() {
        Game game = Game.newGame(3);

        assertThat(game.getPlayers()).hasSize(3);
    }

    @Test
    public void newGame_With3Players_NoMoreThan2PlayersAreGuardians() {
        Game game = Game.newGame(3);

        Collections.shuffle(game.getRoles());
        assertThat(game.getPlayers()).hasSize(3);
    }
}